import 'package:mongo_dart/mongo_dart.dart';

class MongoHelper<T> {
  final Db db;
  final DbCollection collection;

  Db get getDb => db;
  DbCollection get getCollection => collection;

  MongoHelper(this.db, String database, String collection)
      : collection = db.collection(collection);

  MongoHelper.fromUri(String uri, String database, String collection)
      : db = Db(uri),
        collection = Db(uri).collection(collection);

  Future<void> connect() async {
    await db.open();
  }

  Future<void> close() async {
    await db.close(); 
  }

  Future<Map<String, dynamic>?> getOneDocumentByID(ObjectId id) async {
    return await collection.findOne(where.id(id));
  }

  Future<Map<String, dynamic>?> getOneDocumentByField(String field, dynamic value) async {
    return await collection.findOne(where.eq(field, value));
  }

  Future<List<Map<String, dynamic>>> getDocumentsByField(String field, dynamic value) async {
    return await collection.find(where.eq(field, value)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    return await collection.find().toList();
  }

  Future<void> addOneDocument(Map<String, dynamic> document) async {
    await collection.insertOne(document);
  }

  Future<void> addManyDocuments(List<Map<String, dynamic>> documents) async {
    await collection.insertMany(documents);
  }

  Future<void> addElementToArrayInDocument(ObjectId id, String arrayName, dynamic element) async {
    await collection.updateOne(where.id(id), modify.push(arrayName, element));
  }

  Future<void> removeElementFromArrayInDocument(ObjectId id, String arrayName, dynamic element) async {
    await collection.updateOne(where.id(id), modify.pull(arrayName, element));
  }

  Future<void> removeDocumentFromNestedCollection(ObjectId id, String nestedName, ObjectId nestedId) async {
    await collection.updateOne(where.id(id), modify.pull(nestedName, {'_id': nestedId}));
  }

  Future<void> updateFieldInDocument(ObjectId id, String field, dynamic value) async {
    await collection.updateOne(where.id(id), modify.set(field, value));
  }

  Future<void> replaceOneDocument(ObjectId id, Map<String, dynamic> document) async {
    await collection.replaceOne(where.id(id), document);
  }

  Future<void> upsertOneDocument(ObjectId id, Map<String, dynamic> document) async {
    await collection.replaceOne(where.id(id), document, upsert: true);
  }

  Future<void> deleteOneDocumentByID(ObjectId id) async {
    await collection.deleteOne(where.id(id));
  }
}
