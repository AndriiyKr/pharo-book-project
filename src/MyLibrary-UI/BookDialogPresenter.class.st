Class {
	#name : 'BookDialogPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'typeDropList',
		'titleInput',
		'yearInput',
		'pagesInput',
		'illusInput',
		'saveButton',
		'book'
	],
	#category : 'MyLibrary-UI',
	#package : 'MyLibrary-UI'
}

{ #category : 'accessing' }
BookDialogPresenter >> book [
    ^ book
]

{ #category : 'initialization' }
BookDialogPresenter >> connectPresenters [
    typeDropList whenSelectedItemChangedDo: [ :selectedClass |
        selectedClass = Monograph 
            ifTrue: [ illusInput enable ] 
            ifFalse: [ illusInput disable; text: '' ].
            
        selectedClass = MultivolumeBook
            ifTrue: [ pagesInput disable; text: '0' ]
            ifFalse: [ pagesInput enable; text: '' ].
    ].

    saveButton action: [ self processForm ].
]

{ #category : 'layout' }
BookDialogPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: 'Тип видання:' asPresenter expand: false;
        add: typeDropList expand: false;
        add: 'Назва книги:' asPresenter expand: false;
        add: titleInput expand: false;
        add: 'Рік видання:' asPresenter expand: false;
        add: yearInput expand: false;
        add: 'Кількість сторінок:' asPresenter expand: false;
        add: pagesInput expand: false;
        add: 'Кількість ілюстрацій:' asPresenter expand: false;
        add: illusInput expand: false;
        add: saveButton expand: false;
        yourself
]

{ #category : 'accessing' }
BookDialogPresenter >> initializePresenters [
    typeDropList := self newDropList.
    typeDropList items: { SingleVolumeBook . Monograph . MultivolumeBook };
                 display: [ :class | class name ].
                 
    titleInput := self newTextInput placeholder: 'Введіть назву'.
    yearInput := self newNumberInput placeholder: '2024'.
    pagesInput := self newNumberInput placeholder: 'Кількість сторінок'.
    illusInput := self newNumberInput placeholder: 'Тільки для монографій'.
    
    saveButton := self newButton label: 'Створити книгу'; iconName: #smallOk.
    illusInput disable.
]

{ #category : 'accessing' }
BookDialogPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: 'Створення нової книги';
        initialExtent: 400@350.
]

{ #category : 'connections' }
BookDialogPresenter >> processForm [
    | type newBook |
    titleInput text isEmpty ifTrue: [ ^ UIManager default alert: 'Назва не може бути порожньою!' ].
    
    type := typeDropList selectedItem.
    newBook := type new.
    newBook title: titleInput text.
    
    yearInput number ifNotNil: [ :y | newBook year: (Year year: y) ].
    
    type = SingleVolumeBook ifTrue: [ 
        pagesInput number ifNotNil: [ :p | newBook pageCount: p ] 
    ].
    
    type = Monograph ifTrue: [ 
        pagesInput number ifNotNil: [ :p | newBook pageCount: p ].
        illusInput number ifNotNil: [ :i | newBook illustrationCount: i ].
    ].
    
    book := newBook.
    self window close.
]
