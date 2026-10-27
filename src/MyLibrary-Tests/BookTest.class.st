Class {
	#name : 'BookTest',
	#superclass : 'TestCase',
	#instVars : [
		'book'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'tests' }
BookTest >> testAbstractArithmetic [
    | book |
    book := Book new.
    self should: [ book + 10 ] raise: SubclassResponsibility.
    self should: [ book - 5 ] raise: SubclassResponsibility.
    self should: [ book totalVolume ] raise: SubclassResponsibility.
]

{ #category : 'tests' }
BookTest >> testAddAuthor [
    | book realAuthor |
    book := Book new.
    book authors: nil.
    
    realAuthor := Author new firstName: 'Тарас'; lastName: 'Шевченко'.
    book addAuthor: realAuthor.
    
    self assert: book authors size equals: 1.
    self assert: book authors first lastName equals: 'Шевченко'.

    book addAuthor: realAuthor.
    self assert: book authors size equals: 1.
]

{ #category : 'tests' }
BookTest >> testAddPublisher [
    | book realPublisher |
    book := Book new.
    book publishers: nil.
    
    realPublisher := Publisher new name: 'Фоліо'.
    book addPublisher: realPublisher.
    
    self assert: book publishers size equals: 1.
    self assert: book publishers first name equals: 'Фоліо'.
]

{ #category : 'tests' }
BookTest >> testAuthors [
    | book authorsList |
    book := Book new.
    book authors: nil.
    self assert: book authors size equals: 1.
    self assert: book authors first lastName equals: Author defaultAuthor lastName.
    book authors: OrderedCollection new.
    self assert: book authors size equals: 1.

    authorsList := OrderedCollection with: (Author new firstName: 'Іван'; lastName: 'Франко').
    book authors: authorsList.
    self assert: book authors size equals: 1.
    self assert: book authors first firstName equals: 'Іван'.
]

{ #category : 'tests' }
BookTest >> testBookFromDictionary [
    | dict book |
    dict := Dictionary new.
    dict at: 'title' put: 'Кобзар'.
    dict at: 'year' put: (Year year: 1840).
    
    book := Book bookFromDictionary: dict.
    
    self assert: book title equals: 'Кобзар'.
    self assert: book year year equals: 1840.
    self assert: book authors size equals: 1.
    self assert: book publishers size equals: 1.
]

{ #category : 'tests' }
BookTest >> testClassConstructor [
    | book validYear authorsList publishersList |
    validYear := Year year: 2024.
    authorsList := OrderedCollection with: (Author new firstName: 'Леся'; lastName: 'Українка').
    publishersList := OrderedCollection with: (Publisher new name: 'Основи').

    book := Book 
		  authors: authorsList 
        title: 'Лісова пісня' 
		  publishers: publishersList
        year: validYear.

    self assert: book title equals: 'Лісова пісня'.
    self assert: book year equals: validYear.
    self assert: book authors size equals: 1.
    self assert: book authors first firstName equals: 'Леся'.
    self assert: book publishers size equals: 1.
    self assert: book publishers first name equals: 'Основи'.
]

{ #category : 'tests' }
BookTest >> testClassConstructorWithNil [
    | book |
    book := Book 
		  authors: nil 
        title: nil 
		  publishers: nil
        year: nil.
        
    self assert: book title equals: Book defaultTitle.
    self assert: book year equals: Book defaultYear.
    self assert: book authors size equals: 1.
    self assert: book publishers size equals: 1.
]

{ #category : 'tests' }
BookTest >> testComparison [
    | smallBook bigBook |
    smallBook := SingleVolumeBook new pageCount: 100.
    bigBook := SingleVolumeBook new pageCount: 300.
    
    self assert: smallBook < bigBook.
    self assert: bigBook > smallBook.
    self assert: smallBook <= smallBook.
]

{ #category : 'tests' }
BookTest >> testEqualsAndHash [
    | book1 book2 book3 |
    book1 := SingleVolumeBook new title: 'Тест'; year: (Year year: 2020); pageCount: 100.
    book2 := SingleVolumeBook new title: 'Тест'; year: (Year year: 2020); pageCount: 100.
    book3 := SingleVolumeBook new title: 'Інша'; year: (Year year: 2021).
    
    self assert: book1 equals: book2.
    self assert: book1 hash equals: book2 hash.
    self deny: book1 = book3.
]

{ #category : 'tests' }
BookTest >> testPublishers [
    | book pubList |
    book := Book new.
    
    book publishers: nil.
    self assert: book publishers size equals: 1.
    self assert: book publishers first name equals: Publisher defaultPublisher name.
    
    pubList := OrderedCollection with: (Publisher new name: 'А-БА-БА-ГА-ЛА-МА-ГА').
    book publishers: pubList.
    self assert: book publishers size equals: 1.
    self assert: book publishers first name equals: 'А-БА-БА-ГА-ЛА-МА-ГА'.
]

{ #category : 'tests' }
BookTest >> testTitle [
    | book |
    book := Book new.
    book title: 'Програмування на Pharo'.
    self assert: book title equals: 'Програмування на Pharo'.
    book title: nil.
    self assert: book title equals: Book defaultTitle.
    book title: ''.
    self assert: book title equals: Book defaultTitle.
]

{ #category : 'tests' }
BookTest >> testYear [
    | book validYear |
    book := Book new.
    validYear := Year year: 2024.
    book year: validYear.
    self assert: book year equals: validYear.
    book year: nil.
    self assert: book year equals: Book defaultYear.
    self should: [ book year: 2024 ] raise: Error.
]
