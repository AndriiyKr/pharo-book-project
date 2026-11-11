"
Вікно «Картка книги»: показує дані однієї книги лише для перегляду.

Усі текстові поля (назва, рік, тип, специфікація) нередаговані: їх можна виділяти та копіювати, але не змінювати. Списки авторів і видавництв лише показують дані книги, змінити склад авторів чи видавництв тут неможливо.

Public API and Key Messages:
- BookInfoPresenter on: aBook (створює картку для книги; відкривається повідомленням #open)
- detailsDescription (текст «Специфікація типу» для книги)

Instance Variables:
	authorsList	<SpListPresenter> Список авторів (лише перегляд).
	book	<Book> Книга, дані якої показано.
	detailsText	<SpTextPresenter> Специфікація типу книги (лише перегляд).
	publishersList	<SpListPresenter> Список видавництв (лише перегляд).
	titleInput	<SpTextInputFieldPresenter> Назва (лише перегляд).
	typeInput	<SpTextInputFieldPresenter> Тип видання (лише перегляд).
	yearInput	<SpTextInputFieldPresenter> Рік видання (лише перегляд).
"
Class {
	#name : 'BookInfoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'book',
		'titleInput',
		'yearInput',
		'typeInput',
		'authorsList',
		'publishersList',
		'detailsText'
	],
	#category : 'MyLibrary-UI-UI',
	#package : 'MyLibrary-UI',
	#tag : 'UI'
}

{ #category : 'accessing' }
BookInfoPresenter >> authorsList [
    ^ authorsList
]

{ #category : 'accessing' }
BookInfoPresenter >> book [
    ^ book
]

{ #category : 'layout' }
BookInfoPresenter >> defaultLayout [
    | generalInfo listsInfo |
    generalInfo := SpBoxLayout newTopToBottom
        spacing: 5;
        add: (self labelNamed: 'Назва:') expand: false; add: titleInput expand: false;
        add: (self labelNamed: 'Рік:') expand: false; add: yearInput expand: false;
        add: (self labelNamed: 'Тип:') expand: false; add: typeInput expand: false;
        yourself.

    listsInfo := SpBoxLayout newLeftToRight
        spacing: 10;
        add: (SpBoxLayout newTopToBottom
            add: (self labelNamed: 'Автори:') expand: false;
            add: authorsList;
            yourself);
        add: (SpBoxLayout newTopToBottom
            add: (self labelNamed: 'Видавництва:') expand: false;
            add: publishersList;
            yourself);
        yourself.

    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: generalInfo expand: false;
        add: listsInfo;
        add: (self labelNamed: 'Специфікація типу:') expand: false;
        add: detailsText;
        yourself
]

{ #category : 'actions' }
BookInfoPresenter >> detailsDescription [
    "Текст специфікації залежно від типу книги"
    ^ String streamContents: [ :s |
	        (book isKindOf: MultivolumeBook) ifTrue: [
		            s nextPutAll: 'Кількість томів: '; print: book volumes size; cr.
		            book volumes
		                do: [ :each |
			                  s nextPutAll: ' - Том '; print: each volumeNumber;
    								nextPutAll: ' «'; nextPutAll: each titleVolume;
								   nextPutAll: '» ('; print: each pageCount; nextPutAll: ' стор.)' ]
                separatedBy: [ s cr ] ].
        (book isKindOf: SingleVolumeBook) ifTrue: [
	            s nextPutAll: 'Сторінок: '; print: book pageCount ].
        (book isKindOf: Monograph) ifTrue: [
	            s cr; nextPutAll: 'Ілюстрацій: '; print: book illustrationCount ].
        s cr; cr; nextPutAll: 'Загальний обсяг: '; print: book totalVolume ]
]

{ #category : 'accessing' }
BookInfoPresenter >> detailsText [
    ^ detailsText
]

{ #category : 'initialization' }
BookInfoPresenter >> initializePresenters [
    "Усі поля тільки для читання: користувач може їх виділити й скопіювати, але не змінити"
    titleInput := self newReadOnlyInput: book title.
    yearInput := self newReadOnlyInput: book year year asString.
    typeInput := self newReadOnlyInput: book class name asString.
    authorsList := self newList
        items: book authors asArray;
        display: [ :each | each fullName ];
        yourself.
    publishersList := self newList
        items: book publishers asArray;
        display: [ :each | each name ];
        yourself.
    detailsText := self newText
        beNotEditable;
        yourself.
    self populateDetails
]

{ #category : 'initialization' }
BookInfoPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'Картка книги';
        initialExtent: 550@450
]

{ #category : 'private' }
BookInfoPresenter >> labelNamed: aString [
    ^ self newLabel
        label: aString;
        yourself
]

{ #category : 'initialization' }
BookInfoPresenter >> newReadOnlyInput: aString [
    "Однорядкове поле, текст якого не можна редагувати"
    ^ self newTextInput
        text: aString;
        beNotEditable;
        yourself
]

{ #category : 'actions' }
BookInfoPresenter >> populateDetails [
    detailsText text: self detailsDescription
]

{ #category : 'accessing' }
BookInfoPresenter >> publishersList [
    ^ publishersList
]

{ #category : 'initialization' }
BookInfoPresenter >> setModelBeforeInitialization: aBook [
    book := aBook
]

{ #category : 'accessing' }
BookInfoPresenter >> titleInput [
    ^ titleInput
]

{ #category : 'accessing' }
BookInfoPresenter >> typeInput [
    ^ typeInput
]

{ #category : 'accessing' }
BookInfoPresenter >> yearInput [
    ^ yearInput
]
