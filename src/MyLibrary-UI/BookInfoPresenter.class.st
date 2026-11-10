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
	#category : 'MyLibrary-UI',
	#package : 'MyLibrary-UI'
}

{ #category : 'layout' }
BookInfoPresenter >> defaultLayout [
    | generalInfo listsInfo |
    generalInfo := SpBoxLayout newTopToBottom
        spacing: 5;
        add: 'Назва:' asPresenter expand: false; add: titleInput expand: false;
        add: 'Рік:' asPresenter expand: false; add: yearInput expand: false;
        add: 'Тип:' asPresenter expand: false; add: typeInput expand: false;
        yourself.
        
    listsInfo := SpBoxLayout newLeftToRight
        spacing: 10;
        add: (SpBoxLayout newTopToBottom add: 'Автори:' asPresenter expand: false; add: authorsList; yourself);
        add: (SpBoxLayout newTopToBottom add: 'Видавництва:' asPresenter expand: false; add: publishersList; yourself);
        yourself.
        
    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: generalInfo expand: false;
        add: listsInfo;
        add: 'Специфікація типу:' asPresenter expand: false;
        add: detailsText;
        yourself.
]

{ #category : 'initialization' }
BookInfoPresenter >> initializePresenters [
    titleInput := self newTextInput text: book title; disable; yourself.
    yearInput := self newTextInput text: book year year asString; disable; yourself.
    typeInput := self newTextInput text: book class name; disable; yourself.

    authorsList := self newList items: book authors asArray; display: [ :a | a fullName ].
    publishersList := self newList items: book publishers asArray; display: [ :p | p name ].

    detailsText := self newText disable; yourself.
    self populateDetails.
]

{ #category : 'initialization' }
BookInfoPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'Картка книги';
        initialExtent: 550@450.
]

{ #category : 'actions' }
BookInfoPresenter >> populateDetails [
    | str |
    str := String streamContents: [ :s |
        book class = SingleVolumeBook ifTrue: [
            s nextPutAll: 'Сторінок: '; print: book pageCount.
        ].
        book class = Monograph ifTrue: [
            s nextPutAll: 'Сторінок: '; print: book pageCount; cr.
            s nextPutAll: 'Ілюстрацій: '; print: book illustrationCount.
        ].
        book class = MultivolumeBook ifTrue: [
            s nextPutAll: 'Кількість томів: '; print: book volumes size; cr.
            book volumes do: [ :v | 
                s nextPutAll: ' - Том '; print: v volumeNumber; 
                  nextPutAll: ' ('; print: v pageCount; nextPutAll: ' стор.)'; cr.
            ]
        ].
        s cr; cr; nextPutAll: 'Загальний обсяг: '; print: book totalVolume.
    ].
    detailsText text: str.
]

{ #category : 'initialization' }
BookInfoPresenter >> setModelBeforeInitialization: aBook [
    book := aBook.
]
