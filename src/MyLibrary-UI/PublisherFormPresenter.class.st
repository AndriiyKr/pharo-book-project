Class {
	#name : 'PublisherFormPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'nameInput',
		'cityInput',
		'yearInput',
		'saveButton',
		'publisher'
	],
	#category : 'MyLibrary-UI-UI',
	#package : 'MyLibrary-UI',
	#tag : 'UI'
}

{ #category : 'connections' }
PublisherFormPresenter >> connectPresenters [
    saveButton action: [ self processForm ].
]

{ #category : 'layout' }
PublisherFormPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom spacing: 5;
        add: 'Назва:' asPresenter expand: false; add: nameInput expand: false;
        add: 'Місто:' asPresenter expand: false; add: cityInput expand: false;
        add: 'Рік заснування:' asPresenter expand: false; add: yearInput expand: false;
        add: saveButton expand: false;
        yourself
]

{ #category : 'initialization' }
PublisherFormPresenter >> initializeDialogWindow: aDialogWindowPresenter [
    self initializeWindow: aDialogWindowPresenter.
    aDialogWindowPresenter 
        addButton: 'Скасувати' 
        do: [ :dialog | dialog close ].
]

{ #category : 'initialization' }
PublisherFormPresenter >> initializePresenters [
    nameInput := self newTextInput placeholder: 'Назва видавництва'.
    cityInput := self newTextInput placeholder: 'Місто'.
    yearInput := self newNumberInput placeholder: 'Рік (напр. 1990)'.
    saveButton := self newButton label: 'Зберегти'; iconName: #smallOk.
]

{ #category : 'initialization' }
PublisherFormPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter title: 'Нове видавництво'; initialExtent: 350@300.
]

{ #category : 'actions' }
PublisherFormPresenter >> processForm [
    nameInput text isEmpty ifTrue: [ ^ UIManager default alert: 'Введіть назву видавництва!' ].
    
    publisher := Publisher new.
    publisher name: nameInput text.
    
    cityInput text ifNotEmpty: [ :c | publisher city: c ].
    yearInput number ifNotNil: [ :y | 
        [ 
            publisher foundationYear: (Year year: y asInteger).
        ] on: Error do: [ 
            ^ UIManager default alert: 'Невірний формат року!' 
        ]
    ].
    
    self window close.
]

{ #category : 'accessing' }
PublisherFormPresenter >> publisher [
    ^ publisher
]
