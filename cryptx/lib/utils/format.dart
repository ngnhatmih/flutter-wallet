class AddressFormat {
  static String formatAddress(String address) {
    if (address.length < 6) {
      return address;
    }
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class BalanceFormat {
  
}