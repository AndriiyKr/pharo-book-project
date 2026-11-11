"
Інтеграційні тести збереження й завантаження бібліотеки у файл через LibraryPresenter (STON, текстовий експорт, StoreString). Працюють з тимчасовими файлами та залежать від методів Library >> saveToSTON:, exportToText:, saveToStoreString:, loadFromSTON:, Library class >> loadFromStoreString:.
"
Class {
	#name : 'LibraryPresenterFileTest',
	#superclass : 'TestCase',
	#instVars : [
		'library',
		'presenter',
		'baseName'
	],
	#category : 'MyLibrary-UI-Tests',
	#package : 'MyLibrary-UI-Tests'
}

{ #category : 'helpers' }
LibraryPresenterFileTest >> newBookTitled: aTitle year: aYear [
    | newBook |
    newBook := SingleVolumeBook new.
    newBook title: aTitle; year: (Year year: aYear); pageCount: 100.
    newBook addAuthor: (Author new firstName: 'Тарас'; lastName: 'Шевченко'; yourself).
    ^ newBook
]

{ #category : 'running' }
LibraryPresenterFileTest >> setUp [
    super setUp.
    library := Library new.
    library addBook: (self newBookTitled: 'Кобзар' year: 1840).
    library addBook: (self newBookTitled: 'Гайдамаки' year: 1841).
    presenter := LibraryPresenter on: library.
    baseName := (FileLocator temp / 'library_presenter_test') pathString
]

{ #category : 'running' }
LibraryPresenterFileTest >> tearDown [
    #('.ston' '.txt') do: [ :extension | (baseName, extension) asFileReference ensureDelete ].
    super tearDown
]

{ #category : 'tests - saving' }
LibraryPresenterFileTest >> testExportTextCreatesReadableFile [
    presenter saveToFileNamed: baseName format: 2.
    self assert: ((baseName, '.txt') asFileReference contents includesSubstring: 'Кобзар')
]

{ #category : 'tests - loading' }
LibraryPresenterFileTest >> testLoadMissingFileKeepsCurrentLibrary [
    self should: [ presenter loadFromFileNamed: baseName, '_missing' format: 1 ] raise: Error.
    self assert: presenter library == library.
    self assert: presenter booksTable items size equals: 2
]

{ #category : 'tests - loading' }
LibraryPresenterFileTest >> testLoadRejectsUnknownFormat [
    self should: [ presenter loadFromFileNamed: baseName format: 9 ] raise: Error.
    self assert: presenter library == library
]

{ #category : 'tests - loading' }
LibraryPresenterFileTest >> testSTONRoundTrip [
    | other |
    presenter saveToFileNamed: baseName format: 1.
    other := LibraryPresenter on: Library new.
    other loadFromFileNamed: baseName format: 1.
    self assert: (self titlesOf: other library) equals: #('Кобзар' 'Гайдамаки').
    self assert: other booksTable items size equals: 2
]

{ #category : 'tests - saving' }
LibraryPresenterFileTest >> testSaveRejectsUnknownFormat [
    self should: [ presenter saveToFileNamed: baseName format: 9 ] raise: Error
]

{ #category : 'tests - saving' }
LibraryPresenterFileTest >> testSaveSTONCreatesFile [
    presenter saveToFileNamed: baseName format: 1.
    self assert: (baseName, '.ston') asFileReference exists
]

{ #category : 'tests - saving' }
LibraryPresenterFileTest >> testSaveStoreStringCreatesFile [
    presenter saveToFileNamed: baseName format: 3.
    self assert: (baseName, '.txt') asFileReference exists
]

{ #category : 'tests - loading' }
LibraryPresenterFileTest >> testStoreStringRoundTrip [
    | other |
    presenter saveToFileNamed: baseName format: 3.
    other := LibraryPresenter on: Library new.
    other loadFromFileNamed: baseName format: 2.
    self assert: (self titlesOf: other library) equals: #('Кобзар' 'Гайдамаки').
    self assert: other booksTable items size equals: 2
]

{ #category : 'helpers' }
LibraryPresenterFileTest >> titlesOf: aLibrary [
    ^ (aLibrary books collect: [ :each | each title ]) asArray
]
