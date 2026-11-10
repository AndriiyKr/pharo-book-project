Class {
	#name : 'BookDialogPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'library',
		'typeDropList',
		'titleInput',
		'yearInput',
		'authorsList',
		'addExistingAuthorBtn',
		'addNewAuthorBtn',
		'removeAuthorBtn',
		'publishersList',
		'addExistingPubBtn',
		'addNewPubBtn',
		'removePubBtn',
		'dynamicPresenter',
		'pagesInput',
		'illusInput',
		'volumesList',
		'addVolumeBtn',
		'removeVolumeBtn',
		'saveButton',
		'book'
	],
	#category : 'MyLibrary-UI',
	#package : 'MyLibrary-UI'
}

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> addNewVolume [
    | num pages newVol |
    num := UIManager default request: 'Номер тому (ціле число):'. num ifNil: [ ^ self ].
    pages := UIManager default request: 'Кількість сторінок:'. pages ifNil: [ ^ self ].
    newVol := Volume new volumeNumber: num asInteger; pageCount: pages asInteger.
    volumesList items: (volumesList items asOrderedCollection add: newVol; yourself).
]

{ #category : 'accessing' }
BookDialogPresenter >> book [
    ^ book
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> chooseExistingAuthor [
    | existing choice |
    existing := (library books flatCollect: [ :b | b authors ]) asSet asArray.
    existing ifEmpty: [ ^ UIManager default inform: 'Немає наявних авторів!' ].
    choice := UIManager default chooseFrom: (existing collect: #fullName) values: existing title: 'Оберіть автора'.
    choice ifNotNil: [ (authorsList items includes: choice) ifFalse: [ authorsList items: (authorsList items asOrderedCollection add: choice; yourself) ] ].
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> chooseExistingPublisher [
    | existing choice |
    existing := (library books flatCollect: [ :b | b publishers ]) asSet asArray.
    existing ifEmpty: [ ^ UIManager default inform: 'Немає наявних видавництв!' ].
    choice := UIManager default chooseFrom: (existing collect: #name) values: existing title: 'Оберіть видавництво'.
    choice ifNotNil: [ (publishersList items includes: choice) ifFalse: [ publishersList items: (publishersList items asOrderedCollection add: choice; yourself) ] ].
]

{ #category : 'connections' }
BookDialogPresenter >> connectPresenters [
    typeDropList whenSelectedItemChangedDo: [ :cls | self updateDynamicPanel ].
    
    addExistingAuthorBtn action: [ self chooseExistingAuthor ].
    addNewAuthorBtn action: [ self createNewAuthor ].
    removeAuthorBtn action: [ authorsList selection selectedItem ifNotNil: [ :s | authorsList items: (authorsList items asOrderedCollection remove: s; yourself) ] ].
    
    addExistingPubBtn action: [ self chooseExistingPublisher ].
    addNewPubBtn action: [ self createNewPublisher ].
    removePubBtn action: [ publishersList selection selectedItem ifNotNil: [ :s | publishersList items: (publishersList items asOrderedCollection remove: s; yourself) ] ].
    
    addVolumeBtn action: [ self addNewVolume ].
    removeVolumeBtn action: [ volumesList selection selectedItem ifNotNil: [ :s | volumesList items: (volumesList items asOrderedCollection remove: s; yourself) ] ].
    
    saveButton action: [ self processForm ].
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> createNewAuthor [
    | fName lName newAuthor |
    fName := UIManager default request: 'Ім''я автора:'. fName ifNil: [ ^ self ].
    lName := UIManager default request: 'Прізвище автора:'. lName ifNil: [ ^ self ].
    newAuthor := Author new firstName: fName; lastName: lName.
    authorsList items: (authorsList items asOrderedCollection add: newAuthor; yourself).
]

{ #category : 'actions - sub dialog' }
BookDialogPresenter >> createNewPublisher [
    | pName newPub |
    pName := UIManager default request: 'Назва видавництва:'. pName ifNil: [ ^ self ].
    newPub := Publisher new name: pName.
    publishersList items: (publishersList items asOrderedCollection add: newPub; yourself).
]

{ #category : 'layout' }
BookDialogPresenter >> defaultLayout [
    | listsLayout |
    listsLayout := SpBoxLayout newLeftToRight spacing: 10;
        add: (SpBoxLayout newTopToBottom
            add: 'Автори:' asPresenter expand: false;
            add: (SpBoxLayout newLeftToRight spacing: 5; add: addExistingAuthorBtn; add: addNewAuthorBtn; add: removeAuthorBtn; yourself) expand: false;
            add: authorsList; yourself);
        add: (SpBoxLayout newTopToBottom
            add: 'Видавництва:' asPresenter expand: false;
            add: (SpBoxLayout newLeftToRight spacing: 5; add: addExistingPubBtn; add: addNewPubBtn; add: removePubBtn; yourself) expand: false;
            add: publishersList; yourself);
        yourself.
        
    ^ SpBoxLayout newTopToBottom spacing: 5;
        add: 'Тип видання:' asPresenter expand: false; add: typeDropList expand: false;
        add: 'Назва:' asPresenter expand: false; add: titleInput expand: false;
        add: 'Рік:' asPresenter expand: false; add: yearInput expand: false;
        add: listsLayout;
        add: dynamicPresenter;
        add: saveButton expand: false;
        yourself.
]

{ #category : 'initialization' }
BookDialogPresenter >> initializePresenters [
    typeDropList := self newDropList items: { SingleVolumeBook . Monograph . MultivolumeBook }; display: [ :c | c name ].
    titleInput := self newTextInput placeholder: 'Назва'.
    yearInput := self newNumberInput placeholder: 'Рік (напр. 2024)'.
    
    "Автори"
    authorsList := self newList display: [ :a | a fullName ].
    addExistingAuthorBtn := self newButton label: 'Вибрати'; iconName: #smallFind.
    addNewAuthorBtn := self newButton label: 'Новий'; iconName: #smallAdd.
    removeAuthorBtn := self newButton label: 'X'; iconName: #smallDelete.
    
    "Видавництва"
    publishersList := self newList display: [ :p | p name ].
    addExistingPubBtn := self newButton label: 'Вибрати'; iconName: #smallFind.
    addNewPubBtn := self newButton label: 'Нове'; iconName: #smallAdd.
    removePubBtn := self newButton label: 'X'; iconName: #smallDelete.
    
    "Динамічні поля (вони не вставляються одразу, а чекають свого макета)"
    dynamicPresenter := self newPresenter. 
    pagesInput := self newNumberInput.
    illusInput := self newNumberInput.
    volumesList := self newList display: [ :v | 'Том ', v volumeNumber printString, ' (', v pageCount printString, ' стор.)' ].
    addVolumeBtn := self newButton label: 'Додати том'; iconName: #smallAdd.
    removeVolumeBtn := self newButton label: 'Видалити том'; iconName: #smallDelete.
    
    saveButton := self newButton label: 'Створити книгу'; iconName: #smallOk.
    
    self updateDynamicPanel.
]

{ #category : 'initialization' }
BookDialogPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter title: 'Нова книга'; initialExtent: 650@700.
]

{ #category : 'actions' }
BookDialogPresenter >> processForm [
    | type newBook |
    titleInput text isEmpty ifTrue: [ ^ UIManager default alert: 'Введіть назву!' ].
    yearInput number ifNil: [ ^ UIManager default alert: 'Введіть рік!' ].
    
    type := typeDropList selectedItem.
    newBook := type new title: titleInput text; year: (Year year: yearInput number).
    
    authorsList items do: [ :a | newBook addAuthor: a ].
    publishersList items do: [ :p | newBook addPublisher: p ].
    
    type = SingleVolumeBook ifTrue: [
        pagesInput number ifNil: [ ^ UIManager default alert: 'Введіть сторінки!' ].
        newBook pageCount: pagesInput number.
    ].
    type = Monograph ifTrue: [
        pagesInput number ifNil: [ ^ UIManager default alert: 'Введіть сторінки!' ].
        illusInput number ifNil: [ ^ UIManager default alert: 'Введіть ілюстрації!' ].
        newBook pageCount: pagesInput number; illustrationCount: illusInput number.
    ].
    type = MultivolumeBook ifTrue: [
        volumesList items ifEmpty: [ ^ UIManager default alert: 'Додайте хоча б один том!' ].
        volumesList items do: [ :v | newBook + v ].
    ].
    
    book := newBook.
    self window close.
]

{ #category : 'initialization' }
BookDialogPresenter >> setModelBeforeInitialization: aLibrary [
    library := aLibrary.
]

{ #category : 'actions - dynamic UI' }
BookDialogPresenter >> updateDynamicPanel [
    | newLayout selectedClass |
    selectedClass := typeDropList selectedItem.
    newLayout := SpBoxLayout newTopToBottom spacing: 5.
    
    selectedClass = SingleVolumeBook ifTrue: [
        newLayout add: 'Сторінки:' asPresenter expand: false; add: pagesInput expand: false.
    ].
    selectedClass = Monograph ifTrue: [
        newLayout add: 'Сторінки:' asPresenter expand: false; add: pagesInput expand: false;
                  add: 'Ілюстрації:' asPresenter expand: false; add: illusInput expand: false.
    ].
    selectedClass = MultivolumeBook ifTrue: [
        newLayout 
            add: (SpBoxLayout newLeftToRight spacing: 5; add: 'Томи:' asPresenter; add: addVolumeBtn expand: false; add: removeVolumeBtn expand: false; yourself) expand: false;
            add: volumesList.
    ].

    dynamicPresenter layout: newLayout.
]
