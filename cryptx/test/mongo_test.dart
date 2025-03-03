import 'package:mongo_dart/mongo_dart.dart';
import 'package:wallet/utils/mongo_helper.dart'; 
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MongoHelper mongoHelper;
  late Db db;

  setUp(() async {
    const connectionString = "mongodb+srv://ngn:123@cluster0.ilq9j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
    db = await Db.create(connectionString);
    mongoHelper = MongoHelper(db, 'test', 'test_collection');
    await mongoHelper.connect();
  });

  tearDown(() async {
    await mongoHelper.close();
  });

  test('Add and retrieve a document', () async {
    final testDoc = {'name': 'Alice', 'age': 25};
    await mongoHelper.addOneDocument(testDoc);
    final result = await mongoHelper.getOneDocumentByField('name', 'Alice');

    print(result);
    expect(result, isNotNull);
    expect(result!['name'], equals('Alice'));
    expect(result['age'], equals(25));
  });

  test('Update a document field', () async {
    final testDoc = {'name': 'Bob', 'age': 30};
    await mongoHelper.addOneDocument(testDoc);
    final result = await mongoHelper.getOneDocumentByField('name', 'Bob');
    print(result);
    
    expect(result, isNotNull);
    final id = result!['_id'] as ObjectId;
    await mongoHelper.updateFieldInDocument(id, 'age', 35);
    final updatedResult = await mongoHelper.getOneDocumentByID(id);

    expect(updatedResult, isNotNull);
    expect(updatedResult!['age'], equals(35));
  });

  test('Delete a document', () async {
    final testDoc = {'name': 'Charlie', 'age': 40};
    await mongoHelper.addOneDocument(testDoc);
    final result = await mongoHelper.getOneDocumentByField('name', 'Charlie');
    
    expect(result, isNotNull);
    final id = result!['_id'] as ObjectId;
    await mongoHelper.deleteOneDocumentByID(id);
    final deletedResult = await mongoHelper.getOneDocumentByID(id);

    expect(deletedResult, isNull);
  });
}
