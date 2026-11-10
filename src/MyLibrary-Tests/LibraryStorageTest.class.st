Class {
	#name : 'LibraryStorageTest',
	#superclass : 'TestCase',
	#instVars : [
		'library',
		'oldRepository'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'running' }
LibraryStorageTest >> setUp [
    super setUp.
    library := Library new name: 'Тестова БД'.
    library addBook: (SingleVolumeBook new title: 'Тест Книга'; pageCount: 100).
    library addBook: (Monograph new title: 'Монографія'; pageCount: 200; illustrationCount: 20).
]

{ #category : 'tests' }
LibraryStorageTest >> testExportToText [
    | fileName testFile |
    fileName := 'test_export.txt'.
    testFile := fileName asFileReference.
    
    library exportToText: fileName.
    
    self assert: testFile exists.
    self assert: testFile contents isNotEmpty.
    
    testFile ensureDelete.
]

{ #category : 'tests' }
LibraryStorageTest >> testSTONSerialization [
    | fileName testFile loadedLibrary |
    fileName := 'test_library.ston'.
    testFile := fileName asFileReference.
    
    library saveToSTON: fileName.
    loadedLibrary := Library new.
    loadedLibrary loadFromSTON: fileName.
    
    self assert: loadedLibrary books size equals: library books size.
    
    testFile ensureDelete.
]

{ #category : 'tests' }
LibraryStorageTest >> testStoreStringSerialization [
    | fileName testFile loadedLibrary |
    fileName := 'test_storeon.txt'.
    testFile := fileName asFileReference.
    
    library saveToStoreString: fileName.
    loadedLibrary := Library loadFromStoreString: fileName.
    
    self assert: loadedLibrary books size equals: library books size.
    self assert: loadedLibrary name equals: library name.
    
    testFile ensureDelete.
]
