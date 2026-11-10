Class {
	#name : 'SingleVolumeBookTest',
	#superclass : 'TestCase',
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'tests' }
SingleVolumeBookTest >> testArithmeticMinus [

	| book result |
	book := SingleVolumeBook new pageCount: 100.

	result := book - 40.
	self assert: book pageCount equals: 60.
	self assert: result identicalTo: book.

	book - 100.
	self assert: book pageCount equals: SingleVolumeBook defaultPageCount
]

{ #category : 'tests' }
SingleVolumeBookTest >> testArithmeticPlus [

	| book result |
	book := SingleVolumeBook new pageCount: 100.

	result := book + 50.

	self assert: book pageCount equals: 150.
	self assert: result identicalTo: book
]

{ #category : 'tests' }
SingleVolumeBookTest >> testBookFromDictionary [
    | dict book emptyDict emptyBook |
    
    dict := Dictionary new.
    dict at: 'title' put: 'Словник';
         at: 'pageCount' put: 500.
         
    book := SingleVolumeBook bookFromDictionary: dict.
    self assert: book title equals: 'Словник'.
    self assert: book pageCount equals: 500.
    
    emptyDict := Dictionary new.
    emptyBook := SingleVolumeBook bookFromDictionary: emptyDict.
    
    self assert: emptyBook title equals: SingleVolumeBook defaultTitle.
    self assert: emptyBook pageCount equals: SingleVolumeBook defaultPageCount.
]

{ #category : 'tests' }
SingleVolumeBookTest >> testClassConstructor [
    | book year authors pubs |
    year := Year year: 2024.
    authors := OrderedCollection new.
    pubs := OrderedCollection new.
   
    book := SingleVolumeBook
        authors: authors
        title: 'Тестова книга'
        publishers: pubs
        year: year
        pageCount: 250.
        
    self assert: book title equals: 'Тестова книга'.
    self assert: book pageCount equals: 250.
]

{ #category : 'tests' }
SingleVolumeBookTest >> testInitialize [
    | book |
    book := SingleVolumeBook new.
    self assert: book pageCount equals: SingleVolumeBook defaultPageCount.
]

{ #category : 'tests' }
SingleVolumeBookTest >> testPageCountValidation [
    | book |
    book := SingleVolumeBook new.
    book pageCount: 150.
    self assert: book pageCount equals: 150.
    
    book pageCount: nil.
    self assert: book pageCount equals: SingleVolumeBook defaultPageCount.
    
    self should: [ book pageCount: 0 ] raise: Error.
    self should: [ book pageCount: -10 ] raise: Error.
    self should: [ book pageCount: '100' ] raise: Error.
]

{ #category : 'tests' }
SingleVolumeBookTest >> testTotalVolume [
    | book |
    book := SingleVolumeBook new pageCount: 320.
    
    self assert: book totalVolume equals: 320.
]
