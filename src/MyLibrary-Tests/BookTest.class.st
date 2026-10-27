Class {
	#name : 'BookTest',
	#superclass : 'TestCase',
	#instVars : [
		'book'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'running' }
BookTest >> setUp [
    super setUp.
    book := Book new.
]

{ #category : 'tests' }
BookTest >> testAuthorsCollection [
    | testAuthor |
    testAuthor := Author new firstName: 'Михайло'; lastName: 'Коцюбинський'.
    book authors: OrderedCollection new.
    book addAuthor: testAuthor.
    self assert: book authors size equals: 1.
    self assert: book authors first equals: testAuthor.
]

{ #category : 'tests' }
BookTest >> testConstants [
    self assert: Book defaultTitle equals: 'Без назви'.
    self assert: Book defaultAuthorName equals: 'Невідомий автор'.
    self assert: Book defaultPublisherName equals: 'Невідоме видавництво'.
    self assert: Book defaultYearString equals: 'Невідомий рік'.
    self assert: Book pagesPerPrintedSheet equals: 32.
]

{ #category : 'tests' }
BookTest >> testPublishersCollection [
    | testPublisher |
    testPublisher := Publisher new name: 'Фоліо'; city: 'Харків'.
    book publishers: OrderedCollection new.
    book addPublisher: testPublisher.
    self assert: book publishers size equals: 1.
    self assert: book publishers first equals: testPublisher.
]

{ #category : 'tests' }
BookTest >> testTitle [
    book title: 'Тіні забутих предків'.
    self assert: book title equals: 'Тіні забутих предків'.
]

{ #category : 'tests' }
BookTest >> testYearValidation [
    self should: [ book year: 1911 ] raise: Error.
    self should: [ book year: '1911' ] raise: Error.
    book year: (Year year: 1911).
    self assert: book year year equals: 1911.
]
