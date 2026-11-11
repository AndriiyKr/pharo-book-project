"
Інтеграційні тести збереження й завантаження бібліотеки в БД через LibraryPresenter. Використовують окремий репозиторій у пам'яті (VOMemoryRepository), а після тесту повертають попередній репозиторій Voyage, тому справжню БД (MongoDB) не зачіпають. Потребують завантаженого Voyage.
"
Class {
	#name : 'LibraryPresenterDatabaseTest',
	#superclass : 'TestCase',
	#instVars : [
		'library',
		'presenter',
		'previousRepository'
	],
	#category : 'MyLibrary-UI-Tests',
	#package : 'MyLibrary-UI-Tests'
}

{ #category : 'helpers' }
LibraryPresenterDatabaseTest >> newBookTitled: aTitle year: aYear [
    | newBook |
    newBook := SingleVolumeBook new.
    newBook title: aTitle; year: (Year year: aYear); pageCount: 100.
    newBook addAuthor: (Author new firstName: 'Тарас'; lastName: 'Шевченко'; yourself).
    ^ newBook
]

{ #category : 'running' }
LibraryPresenterDatabaseTest >> setUp [
    super setUp.
    previousRepository := [ VORepository current ] on: Error do: [ :error | nil ].
    VOMemoryRepository new enableSingleton.
    library := Library new.
    library addBook: (self newBookTitled: 'Кобзар' year: 1840).
    library addBook: (self newBookTitled: 'Гайдамаки' year: 1841).
    presenter := LibraryPresenter on: library
]

{ #category : 'running' }
LibraryPresenterDatabaseTest >> tearDown [
    VORepository setRepository: previousRepository.
    super tearDown
]

{ #category : 'tests' }
LibraryPresenterDatabaseTest >> testLoadSavedLibraryByName [
    | other |
    presenter saveToDatabaseAs: 'Збережена'.
    other := LibraryPresenter on: Library new.
    self assert: (other loadFromDatabaseNamed: 'Збережена').
    self assert: other library books size equals: 2.
    self assert: other booksTable items size equals: 2
]

{ #category : 'tests' }
LibraryPresenterDatabaseTest >> testLoadUnknownNameKeepsCurrentLibrary [
    self deny: (presenter loadFromDatabaseNamed: 'Не існує').
    self assert: presenter library == library.
    self assert: presenter booksTable items size equals: 2
]

{ #category : 'tests' }
LibraryPresenterDatabaseTest >> testSaveUnderNewNameWorksWithCopy [
    library name: 'Основна'.
    presenter saveToDatabaseAs: 'Філія'.
    self deny: presenter library == library.
    self assert: presenter library name equals: 'Філія'.
    self assert: presenter library books size equals: 2.
    self assert: library name equals: 'Основна'
]

{ #category : 'tests' }
LibraryPresenterDatabaseTest >> testSaveUnderSameNameKeepsLibrary [
    library name: 'Основна'.
    presenter saveToDatabaseAs: 'Основна'.
    self assert: presenter library == library.
    self assert: library name equals: 'Основна'
]
