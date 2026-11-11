"
Тести картки книги BookInfoPresenter: правильність показаних даних і те, що картка лише для перегляду.
"
Class {
	#name : 'BookInfoPresenterTest',
	#superclass : 'TestCase',
	#category : 'MyLibrary-UI-Tests',
	#package : 'MyLibrary-UI-Tests'
}

{ #category : 'helpers' }
BookInfoPresenterTest >> newMonograph [
    | newBook |
    newBook := Monograph new.
    newBook title: 'Монографія'; year: (Year year: 2001); pageCount: 200; illustrationCount: 10.
    ^ newBook
]

{ #category : 'helpers' }
BookInfoPresenterTest >> newMultivolumeBook [
    | newBook |
    newBook := MultivolumeBook new.
    newBook title: 'Енциклопедія'; year: (Year year: 2000).
    newBook addVolume: (Volume number: 1 pages: 200 title: 'А').
    newBook addVolume: (Volume number: 2 pages: 300 title: 'Б').
    ^ newBook
]

{ #category : 'helpers' }
BookInfoPresenterTest >> newSingleVolumeBook [
    | newBook |
    newBook := SingleVolumeBook new.
    newBook title: 'Кобзар'; year: (Year year: 1840); pageCount: 100.
    newBook addAuthor: (Author new firstName: 'Тарас'; lastName: 'Шевченко'; yourself).
    newBook addPublisher: (Publisher new name: 'Дніпро'; yourself).
    ^ newBook
]

{ #category : 'tests' }
BookInfoPresenterTest >> testDetailsOfMonograph [
    | text |
    text := (BookInfoPresenter on: self newMonograph) detailsText text.
    self assert: (text includesSubstring: 'Сторінок: 200').
    self assert: (text includesSubstring: 'Ілюстрацій: 10').
    self assert: (text includesSubstring: 'Загальний обсяг: 210')
]

{ #category : 'tests' }
BookInfoPresenterTest >> testDetailsOfMultivolumeBook [
    | text |
    text := (BookInfoPresenter on: self newMultivolumeBook) detailsText text.
    self assert: (text includesSubstring: 'Кількість томів: 2').
    self assert: (text includesSubstring: ' - Том 1 «А» (200 стор.)').
    self assert: (text includesSubstring: ' - Том 2 «Б» (300 стор.)').
    self assert: (text includesSubstring: 'Загальний обсяг: 500')
]

{ #category : 'tests' }
BookInfoPresenterTest >> testDetailsOfSingleVolumeBook [
    | text |
    text := (BookInfoPresenter on: self newSingleVolumeBook) detailsText text.
    self assert: (text includesSubstring: 'Сторінок: 100').
    self assert: (text includesSubstring: 'Загальний обсяг: 100').
    self deny: (text includesSubstring: 'Ілюстрацій')
]

{ #category : 'tests' }
BookInfoPresenterTest >> testPresenterDoesNotChangeBook [
    | aBook presenter |
    aBook := self newSingleVolumeBook.
    presenter := BookInfoPresenter on: aBook.
    self assert: presenter book == aBook.
    self assert: aBook title equals: 'Кобзар'.
    self assert: aBook pageCount equals: 100
]

{ #category : 'tests' }
BookInfoPresenterTest >> testShowsAuthorsAndPublishers [
    | presenter |
    presenter := BookInfoPresenter on: self newSingleVolumeBook.
    self assert: (presenter authorsList items collect: [ :each | each fullName ]) asArray equals: #('Тарас Шевченко').
    self assert: (presenter publishersList items collect: [ :each | each name ]) asArray equals: #('Дніпро')
]

{ #category : 'tests' }
BookInfoPresenterTest >> testShowsGeneralInformation [
    | presenter |
    presenter := BookInfoPresenter on: self newSingleVolumeBook.
    self assert: presenter titleInput text equals: 'Кобзар'.
    self assert: presenter yearInput text equals: '1840'.
    self assert: presenter typeInput text equals: 'SingleVolumeBook'
]

{ #category : 'tests' }
BookInfoPresenterTest >> testTextFieldsAreNotEditable [
    | presenter |
    presenter := BookInfoPresenter on: self newSingleVolumeBook.
    self deny: presenter titleInput isEditable.
    self deny: presenter yearInput isEditable.
    self deny: presenter typeInput isEditable.
    self deny: presenter detailsText isEditable
]
