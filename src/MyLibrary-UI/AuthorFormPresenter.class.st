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
	#category : 'MyLibrary-UI',
	#package : 'MyLibrary-UI'
}

{ #category : 'accessing' }
AuthorFormPresenter >> author [
    ^ author
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
AuthorFormPresenter >> initializePresenters [
    firstNameInput := self newTextInput placeholder: 'Ім''я'.
    lastNameInput := self newTextInput placeholder: 'Прізвище'.
    birthDateInput := self newTextInput placeholder: 'ДД.ММ.РРРР'.
    cityInput := self newTextInput placeholder: 'Місто'.
    saveButton := self newButton label: 'Зберегти'; iconName: #smallOk.
]

{ #category : 'initialization' }
AuthorFormPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter title: 'Новий автор'; initialExtent: 350@300.
]
