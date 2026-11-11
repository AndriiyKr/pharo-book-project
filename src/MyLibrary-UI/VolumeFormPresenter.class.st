Class {
	#name : 'VolumeFormPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'numberInput',
		'pagesInput',
		'titleInput',
		'saveButton',
		'volume'
	],
	#category : 'MyLibrary-UI-UI',
	#package : 'MyLibrary-UI',
	#tag : 'UI'
}

{ #category : 'connections' }
VolumeFormPresenter >> connectPresenters [
    saveButton action: [ self processForm ].
]

{ #category : 'layout' }
VolumeFormPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom spacing: 5;
        add: 'Номер тому:' asPresenter expand: false; add: numberInput expand: false;
        add: 'Кількість сторінок:' asPresenter expand: false; add: pagesInput expand: false;
        add: 'Назва тому:' asPresenter expand: false; add: titleInput expand: false;
        add: saveButton expand: false;
        yourself
]

{ #category : 'initialization' }
VolumeFormPresenter >> initializeDialogWindow: aDialogWindowPresenter [
    self initializeWindow: aDialogWindowPresenter.
    aDialogWindowPresenter 
        addButton: 'Скасувати' 
        do: [ :dialog | dialog close ].
]

{ #category : 'initialization' }
VolumeFormPresenter >> initializePresenters [
    numberInput := self newNumberInput placeholder: 'Номер тому'.
    pagesInput := self newNumberInput placeholder: 'Кількість сторінок'.
    titleInput := self newTextInput placeholder: 'Назва тому (необов''язково)'.
    saveButton := self newButton label: 'Зберегти'; iconName: #smallOk.
]

{ #category : 'initialization' }
VolumeFormPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter title: 'Новий том'; initialExtent: 350@300.
]

{ #category : 'actions' }
VolumeFormPresenter >> processForm [
    (numberInput number isNil or: [ pagesInput number isNil ]) 
        ifTrue: [ ^ UIManager default alert: 'Введіть номер та кількість сторінок!' ].
        
    volume := Volume new.
    volume volumeNumber: numberInput number.
    volume pageCount: pagesInput number.
    titleInput text ifNotEmpty: [ :t | volume titleVolume: t ].
    
    self window close.
]

{ #category : 'accessing' }
VolumeFormPresenter >> volume [
    ^ volume
]
