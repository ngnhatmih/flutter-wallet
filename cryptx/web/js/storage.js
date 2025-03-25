function savePassword(password) {
  const data = JSON.stringify({ password: password });
  localStorage.setItem("password", data);
}

function getPassword() {
  const data = localStorage.getItem("password");
  if (data) {
    try {
      const parsedData = JSON.parse(data);
      return parsedData.password || null;
    } catch (error) {
      console.error("Error parsing stored password:", error);
      return null;
    }
  }
  return null;
}

async function encryptData(data, password) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const keyMaterial = await getKeyMaterial(password);
  const key = await deriveKey(keyMaterial, salt);

  const encoder = new TextEncoder();
  const encodedData = encoder.encode(data);

  const encryptedData = await crypto.subtle.encrypt(
    {
      name: "AES-GCM",
      iv: iv,
    },
    key,
    encodedData
  );

  return {
    data: btoa(String.fromCharCode(...new Uint8Array(encryptedData))), // Base64 encode
    iv: btoa(String.fromCharCode(...iv)),
    salt: btoa(String.fromCharCode(...salt)),
  };
}

async function decryptData(encryptedData, password) {
  try {
    const salt = new Uint8Array(atob(encryptedData.salt).split("").map(c => c.charCodeAt(0)));
    const iv = new Uint8Array(atob(encryptedData.iv).split("").map(c => c.charCodeAt(0)));
    const keyMaterial = await getKeyMaterial(password);
    const key = await deriveKey(keyMaterial, salt);

    const encryptedBytes = new Uint8Array(atob(encryptedData.data).split("").map(c => c.charCodeAt(0)));

    const decryptedData = await crypto.subtle.decrypt(
      {
        name: "AES-GCM",
        iv: iv,
      },
      key,
      encryptedBytes
    );

    return new TextDecoder().decode(decryptedData);
  } catch (error) {
    console.error("Decryption failed:", error);
    return null; // Return null on decryption failure
  }
}

async function getKeyMaterial(password) {
  return crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(password),
    "PBKDF2",
    false,
    ["deriveKey"]
  );
}

async function deriveKey(keyMaterial, salt) {
  return crypto.subtle.deriveKey(
    {
      name: "PBKDF2",
      salt: salt,
      iterations: 600000,
      hash: "SHA-256",
    },
    keyMaterial,
    { name: "AES-GCM", length: 256 },
    false,
    ["encrypt", "decrypt"]
  );
}

async function saveToSecureStorage(key, value, password) {
  try {
    const encryptedData = await encryptData(value, password);
    localStorage.setItem(key, JSON.stringify(encryptedData));
  } catch (error) {
    console.error("Error saving to secure storage:", error);
  }
}

async function getFromSecureStorage(key, password) {
  try {
    const encryptedData = localStorage.getItem(key);
    if (!encryptedData) return null;

    return await decryptData(JSON.parse(encryptedData), password);
  } catch (error) {
    console.error("Error retrieving from secure storage:", error);
    return null;
  }
}

window.getFromSecureStorage = getFromSecureStorage;
window.saveToSecureStorage = saveToSecureStorage;
window.getPassword = getPassword;
window.savePassword = savePassword;
