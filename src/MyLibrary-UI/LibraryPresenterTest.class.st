"
Тести головного вікна LibraryPresenter: вміст таблиці, рядок стану, пошук за автором і роком, скидання фільтра та видалення книги.
"
Class {
	#name : 'LibraryPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'library',
		'presenter',
		'kobzar',
		'haidamaky',
		'lisovaPisnia'
	],
	#category : 'MyLibrary-UI-Tests',
	#package : 'MyLibrary-UI',
	#tag : 'Tests'
}

{ #category : 'helpers' }
LibraryPresenterTest >> newBookTitled: aTitle year: aYear author: anAuthor [
    | newBook |
    newBook := SingleVolumeBook new.
    newBook title: aTitle; year: (Year year: aYear); pageCount: 100.
    newBook addAuthor: anAuthor.
    ^ newBook
]

{ #category : 'running' }
LibraryPresenterTest >> setUp [
    super setUp.
    library := Library new.
    kobzar := self newBookTitled: 'Кобзар' year: 1840 author: (Author new firstName: 'Тарас'; lastName: 'Шевченко'; yourself).
    haidamaky := self newBookTitled: 'Гайдамаки' year: 1841 author: (Author new firstName: 'Тарас'; lastName: 'Шевченко'; yourself).
    lisovaPisnia := self newBookTitled: 'Лісова пісня' year: 1911 author: (Author new firstName: 'Леся'; lastName: 'Українка'; yourself).
    library addBook: kobzar; addBook: haidamaky; addBook: lisovaPisnia.
    presenter := LibraryPresenter on: library
]

{ #category : 'tests' }
LibraryPresenterTest >> testFilterByAuthor [
    presenter filterByAuthor: 'шевч'.
    self assert: presenter booksTable items size equals: 2.
    self assert: (presenter statusBar label includesSubstring: 'знайдено 2')
]

{ #category : 'tests' }
LibraryPresenterTest >> testFilterByAuthorIgnoresCaseAndSpaces [
    presenter filterByAuthor: '  УКРАЇНКА '.
    self assert: presenter booksTable items asArray equals: { lisovaPisnia }
]

{ #category : 'tests' }
LibraryPresenterTest >> testFilterByAuthorWithoutMatches [
    presenter filterByAuthor: 'Франко'.
    self assert: presenter booksTable items isEmpty.
    self assert: (presenter statusBar label includesSubstring: 'знайдено 0')
]

{ #category : 'tests' }
LibraryPresenterTest >> testFilterByYear [
    presenter filterByYear: 1911.
    self assert: presenter booksTable items asArray equals: { lisovaPisnia }
]

{ #category : 'tests' }
LibraryPresenterTest >> testFilterByYearWithoutMatches [
    presenter filterByYear: 1999.
    self assert: presenter booksTable items isEmpty
]

{ #category : 'tests' }
LibraryPresenterTest >> testPresenterUsesGivenLibrary [
    "Регресія: вікно має працювати з бібліотекою, переданою через #on:, а не створювати власну"
    self assert: presenter library == library
]

{ #category : 'tests' }
LibraryPresenterTest >> testRemoveFromFilteredTableUpdatesLibrary [
    presenter filterByAuthor: 'Шевченко'.
    presenter booksTable selectItem: haidamaky.
    presenter removeSelectedBook.
    self deny: (library books includes: haidamaky).
    self assert: library totalCopies equals: 2
]

{ #category : 'tests' }
LibraryPresenterTest >> testRemoveSelectedBook [
    presenter booksTable selectItem: lisovaPisnia.
    presenter removeSelectedBook.
    self assert: library totalCopies equals: 2.
    self deny: (library books includes: lisovaPisnia).
    self assert: presenter booksTable items size equals: 2
]

{ #category : 'tests' }
LibraryPresenterTest >> testRemoveWithoutSelectionKeepsBooks [
    presenter booksTable unselectAll.
    presenter removeSelectedBook.
    self assert: library totalCopies equals: 3.
    self assert: presenter booksTable items size equals: 3
]

{ #category : 'tests' }
LibraryPresenterTest >> testSaveAndLoadFormatsAreDefined [
    self assert: presenter saveFormats size equals: 3.
    self assert: presenter loadFormats size equals: 2
]

{ #category : 'tests' }
LibraryPresenterTest >> testStatusBarShowsStatistics [
    self assert: (presenter statusBar label includesSubstring: 'Всього примірників: 3')
]

{ #category : 'tests' }
LibraryPresenterTest >> testTableShowsAllBooks [
    self assert: presenter booksTable items size equals: 3
]

{ #category : 'tests' }
LibraryPresenterTest >> testUpdateUIResetsFilter [
    presenter filterByYear: 1911.
    presenter updateUI.
    self assert: presenter booksTable items size equals: 3.
    self assert: (presenter statusBar label includesSubstring: 'Всього примірників: 3')
]
