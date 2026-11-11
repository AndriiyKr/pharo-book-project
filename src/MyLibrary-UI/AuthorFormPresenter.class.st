Class {
	#name : 'AuthorFormPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'firstNameInput',
		'lastNameInput',
		'birthDateInput',
		'cityInput',
		'saveButton',
		'author'
	],
	#category : 'MyLibrary-UI-UI',
	#package : 'MyLibrary-UI',
	#tag : 'UI'
}

{ #category : 'accessing' }
AuthorFormPresenter >> author [
    ^ author
]

{ #category : 'connections' }
AuthorFormPresenter >> connectPresenters [
    saveButton action: [ self processForm ].
]

{ #category : 'layout' }
AuthorFormPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom spacing: 5;
        add: 'Ім''я:' asPresenter expand: false; add: firstNameInput expand: false;
        add: 'Прізвище:' asPresenter expand: false; add: lastNameInput expand: false;
        add: 'Дата народження:' asPresenter expand: false; add: birthDateInput expand: false;
        add: 'Місто:' asPresenter expand: false; add: cityInput expand: false;
        add: saveButton expand: false;
        yourself
]

{ #category : 'initialization' }
AuthorFormPresenter >> initializeDialogWindow: aDialogWindowPresenter [
    self initializeWindow: aDialogWindowPresenter.
    aDialogWindowPresenter 
        addButton: 'Скасувати' 
        do: [ :dialog | dialog close ].
]

{ #category : 'initialization' }
AuthorFormPresenter >> initializePresenters [
    firstNameInput := self newTextInput placeholder: 'Ім''я'.
    lastNameInput := self newTextInput placeholder: 'Прізвище'.
    birthDateInput := self newTextInput placeholder: 'ДД.ММ.РРРР'.
    cityInput := self newTextInput placeholder: 'Місто'.
    saveButton := self newButton label: 'Зберегти'; iconName: #smallOk.
]

{ #category : 'initialization' }
AuthorFormPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter title: 'Новий автор'; initialExtent: 350@350.
]

{ #category : 'actions' }
AuthorFormPresenter >> processForm [
    | parsedDate |
    (firstNameInput text isEmpty or: [ lastNameInput text isEmpty ]) 
        ifTrue: [ ^ UIManager default alert: 'Заповніть ім''я та прізвище!' ].
        
    author := Author new.
    author firstName: firstNameInput text; lastName: lastNameInput text.
    
    cityInput text ifNotEmpty: [ :c | author city: c ].
    
    birthDateInput text ifNotEmpty: [ :textDate | 
        [
            parsedDate := Date readFrom: textDate readStream pattern: 'd.m.y'.
            author birthDate: parsedDate.
        ] on: Error do: [ 
            ^ UIManager default alert: 'Неправильний формат дати! Будь ласка, введіть дату як день.місяць.рік (наприклад: 24.08.1991)' 
        ]
    ]. 
    
    self window close.
]
