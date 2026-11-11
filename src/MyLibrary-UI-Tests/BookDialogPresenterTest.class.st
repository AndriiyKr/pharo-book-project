"
Тести діалогу створення книги BookDialogPresenter: список наявних авторів і видавництв без повторів за іменем, додавання/видалення елементів та збирання книги з форми.
"
Class {
	#name : 'BookDialogPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'library',
		'dialog'
	],
	#category : 'MyLibrary-UI-Tests',
	#package : 'MyLibrary-UI-Tests'
}

{ #category : 'helpers' }
BookDialogPresenterTest >> addBookWithAuthors: authors publishers: publishers [
    | newBook |
    newBook := SingleVolumeBook new.
    newBook title: 'Книга'; year: (Year year: 1840); pageCount: 100.
    authors do: [ :each | newBook addAuthor: each ].
    publishers do: [ :each | newBook addPublisher: each ].
    library addBook: newBook
]

{ #category : 'helpers' }
BookDialogPresenterTest >> authorNamed: aFirstName surname: aLastName [
    ^ Author new firstName: aFirstName; lastName: aLastName; yourself
]

{ #category : 'helpers' }
BookDialogPresenterTest >> fillSingleVolumeForm [
    dialog typeDropList selectItem: SingleVolumeBook.
    dialog titleInput text: 'Заповіт'.
    dialog yearInput number: 1845.
    dialog pagesInput number: 120
]

{ #category : 'helpers' }
BookDialogPresenterTest >> publisherNamed: aName [
    ^ Publisher new name: aName; yourself
]

{ #category : 'running' }
BookDialogPresenterTest >> setUp [
    super setUp.
    library := Library new.
    dialog := BookDialogPresenter on: library
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testAddAuthorIgnoresSameName [
    self assert: (dialog addAuthor: (self authorNamed: 'Тарас' surname: 'Шевченко')).
    self deny: (dialog addAuthor: (self authorNamed: 'Тарас' surname: 'Шевченко')).
    self assert: dialog authorsList items size equals: 1
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testAddAuthorIgnoresSameNameWithDifferentBirthDate [
    | older younger |
    older := self authorNamed: 'Тарас' surname: 'Шевченко'.
    older birthDate: (Date newDay: 9 month: 3 year: 1814).
    younger := self authorNamed: 'Тарас' surname: 'Шевченко'.
    younger birthDate: (Date newDay: 1 month: 1 year: 1990).
    self assert: (dialog addAuthor: older).
    self deny: (dialog addAuthor: younger).
    self assert: dialog authorsList items size equals: 1
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testAddPublisherIgnoresSameName [
    self assert: (dialog addPublisher: (self publisherNamed: 'Дніпро')).
    self deny: (dialog addPublisher: (self publisherNamed: 'Дніпро')).
    self assert: dialog publishersList items size equals: 1
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testAddVolume [
    dialog addVolumeNumber: 1 pages: 100.
    dialog addVolumeNumber: 2 pages: 200.
    self assert: dialog volumesList items size equals: 2
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testAddVolumeRejectsDuplicateNumber [
    dialog addVolumeNumber: 1 pages: 100.
    self should: [ dialog addVolumeNumber: 1 pages: 200 ] raise: Error.
    self assert: dialog volumesList items size equals: 1
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testAddVolumeRejectsInvalidData [
    self should: [ dialog addVolumeNumber: 1 pages: 0 ] raise: Error.
    self should: [ dialog addVolumeNumber: 1 pages: nil ] raise: Error.
    self should: [ dialog addVolumeNumber: nil pages: 10 ] raise: Error.
    self should: [ dialog addVolumeNumber: 0 pages: 10 ] raise: Error.
    self assert: dialog volumesList items isEmpty
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildKeepsSelectedAuthorsAndPublishers [
    | newBook |
    self fillSingleVolumeForm.
    dialog addAuthor: (self authorNamed: 'Тарас' surname: 'Шевченко').
    dialog addPublisher: (self publisherNamed: 'Дніпро').
    newBook := dialog buildBook.
    self assert: (newBook authors collect: [ :each | each fullName ]) asArray equals: #('Тарас Шевченко').
    self assert: (newBook publishers collect: [ :each | each name ]) asArray equals: #('Дніпро')
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildMonograph [
    | newBook |
    dialog typeDropList selectItem: Monograph.
    dialog titleInput text: 'Дослідження'.
    dialog yearInput number: 2020.
    dialog pagesInput number: 200.
    dialog illusInput number: 15.
    newBook := dialog buildBook.
    self assert: newBook class equals: Monograph.
    self assert: newBook pageCount equals: 200.
    self assert: newBook illustrationCount equals: 15.
    self assert: newBook totalVolume equals: 215
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildMultivolumeBook [
    | newBook |
    dialog typeDropList selectItem: MultivolumeBook.
    dialog titleInput text: 'Енциклопедія'.
    dialog yearInput number: 2000.
    dialog addVolumeNumber: 1 pages: 200.
    dialog addVolumeNumber: 2 pages: 300.
    newBook := dialog buildBook.
    self assert: newBook class equals: MultivolumeBook.
    self assert: newBook volumeCount equals: 2.
    self assert: newBook totalVolume equals: 500
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildRejectsEmptyMultivolumeBook [
    dialog typeDropList selectItem: MultivolumeBook.
    dialog titleInput text: 'Енциклопедія'.
    dialog yearInput number: 2000.
    self should: [ dialog buildBook ] raise: Error
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildRejectsInvalidPages [
    self fillSingleVolumeForm.
    dialog pagesInput number: 0.
    self should: [ dialog buildBook ] raise: Error.
    dialog pagesInput number: -5.
    self should: [ dialog buildBook ] raise: Error
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildRequiresTitle [
    self fillSingleVolumeForm.
    dialog titleInput text: '   '.
    self should: [ dialog buildBook ] raise: Error
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildRequiresYear [
    dialog typeDropList selectItem: SingleVolumeBook.
    dialog titleInput text: 'Заповіт'.
    dialog pagesInput number: 120.
    self should: [ dialog buildBook ] raise: Error
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildSingleVolumeBook [
    | newBook |
    self fillSingleVolumeForm.
    newBook := dialog buildBook.
    self assert: newBook class equals: SingleVolumeBook.
    self assert: newBook title equals: 'Заповіт'.
    self assert: newBook year year equals: 1845.
    self assert: newBook pageCount equals: 120
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testBuildWithoutAuthorsUsesDefaultAuthor [
    | newBook |
    self fillSingleVolumeForm.
    newBook := dialog buildBook.
    self assert: newBook authors first lastName equals: Author defaultLastName.
    self assert: newBook publishers first name equals: Publisher defaultName
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingAuthorsAreUniqueByName [
    self addBookWithAuthors: { self authorNamed: 'Тарас' surname: 'Шевченко' } publishers: #().
    self addBookWithAuthors: { self authorNamed: 'Тарас' surname: 'Шевченко' . self authorNamed: 'Леся' surname: 'Українка' } publishers: #().
    self
        assert: (dialog existingAuthors collect: [ :each | each fullName ]) asArray
        equals: #('Тарас Шевченко' 'Леся Українка')
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingAuthorsAreUniqueByNameEvenWithDifferentBirthDates [
    "Author >> = враховує дату народження, але в списку вибору автори з однаковим іменем мають бути одним записом"
    | older younger |
    older := self authorNamed: 'Тарас' surname: 'Шевченко'.
    older birthDate: (Date newDay: 9 month: 3 year: 1814).
    younger := self authorNamed: 'Тарас' surname: 'Шевченко'.
    younger birthDate: (Date newDay: 1 month: 1 year: 1990).
    self deny: older = younger.
    self addBookWithAuthors: { older } publishers: #().
    self addBookWithAuthors: { younger } publishers: #().
    self assert: dialog existingAuthors size equals: 1
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingAuthorsDistinguishDifferentPeople [
    self addBookWithAuthors: { self authorNamed: 'Тарас' surname: 'Шевченко' . self authorNamed: 'Олена' surname: 'Шевченко' } publishers: #().
    self assert: dialog existingAuthors size equals: 2
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingAuthorsIgnoreCaseAndSpaces [
    self addBookWithAuthors: { self authorNamed: 'Тарас' surname: 'Шевченко' } publishers: #().
    self addBookWithAuthors: { self authorNamed: ' тарас ' surname: 'ШЕВЧЕНКО' } publishers: #().
    self assert: dialog existingAuthors size equals: 1
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingAuthorsOfEmptyLibrary [
    self assert: dialog existingAuthors isEmpty
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingPublishersAreUniqueByName [
    self addBookWithAuthors: #() publishers: { self publisherNamed: 'Дніпро' }.
    self addBookWithAuthors: #() publishers: { self publisherNamed: 'Дніпро' . self publisherNamed: 'Основи' }.
    self
        assert: (dialog existingPublishers collect: [ :each | each name ]) asArray
        equals: #('Дніпро' 'Основи')
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingPublishersAreUniqueByNameEvenWithDifferentFoundationYears [
    | first second |
    first := self publisherNamed: 'Дніпро'.
    first foundationYear: (Year year: 1920).
    second := self publisherNamed: 'Дніпро'.
    second foundationYear: (Year year: 1999).
    self deny: first = second.
    self addBookWithAuthors: #() publishers: { first }.
    self addBookWithAuthors: #() publishers: { second }.
    self assert: dialog existingPublishers size equals: 1
]

{ #category : 'tests - existing items' }
BookDialogPresenterTest >> testExistingPublishersIgnoreCaseAndSpaces [
    self addBookWithAuthors: #() publishers: { self publisherNamed: 'Дніпро' }.
    self addBookWithAuthors: #() publishers: { self publisherNamed: '  дніпро ' }.
    self assert: dialog existingPublishers size equals: 1
]

{ #category : 'tests - building' }
BookDialogPresenterTest >> testProcessFormStoresBook [
    self assert: dialog book isNil.
    self fillSingleVolumeForm.
    dialog processForm.
    self assert: dialog book notNil.
    self assert: dialog book title equals: 'Заповіт'
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testRemoveSelectedAuthor [
    | first second |
    first := self authorNamed: 'Тарас' surname: 'Шевченко'.
    second := self authorNamed: 'Леся' surname: 'Українка'.
    dialog addAuthor: first.
    dialog addAuthor: second.
    dialog authorsList selectItem: first.
    dialog removeSelectedAuthor.
    self assert: dialog authorsList items asArray equals: { second }
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testRemoveSelectedPublisher [
    | first second |
    first := self publisherNamed: 'Дніпро'.
    second := self publisherNamed: 'Основи'.
    dialog addPublisher: first.
    dialog addPublisher: second.
    dialog publishersList selectItem: second.
    dialog removeSelectedPublisher.
    self assert: dialog publishersList items asArray equals: { first }
]

{ #category : 'tests - lists' }
BookDialogPresenterTest >> testRemoveSelectedVolume [
    | volume |
    dialog addVolumeNumber: 1 pages: 100.
    volume := dialog addVolumeNumber: 2 pages: 200.
    dialog volumesList selectItem: volume.
    dialog removeSelectedVolume.
    self assert: dialog volumesList items size equals: 1.
    self assert: dialog volumesList items first volumeNumber equals: 1
]
