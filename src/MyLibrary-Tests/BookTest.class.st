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
