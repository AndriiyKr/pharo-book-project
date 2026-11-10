Class {
	#name : 'LibraryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'library',
		'booksTable',
		'addButton',
		'removeButton',
		'saveFileButton',
		'loadFileButton',
		'saveDbButton',
		'statusBar'
	],
	#category : 'MyLibrary-UI',
	#package : 'MyLibrary-UI'
}

{ #category : 'connections' }
LibraryPresenter >> connectPresenters [
    addButton action: [ self openAddBookDialog ].
    removeButton action: [ self removeSelectedBook ].
    
		"Олег тут також зміниш!!!"
    saveFileButton action: [ UIManager default inform: 'Тут буде діалог збереження у файл (STON/TXT)' ].
    loadFileButton action: [ UIManager default inform: 'Тут буде діалог відкриття файлу' ].
    saveDbButton action: [ UIManager default inform: 'Тут буде підключення до MongoDB (Voyage)' ].
]

{ #category : 'layout' }
LibraryPresenter >> defaultLayout [
    | toolbarLayout |
    toolbarLayout := SpBoxLayout newLeftToRight
        spacing: 5;
        add: addButton; 
        add: removeButton;
        add: saveFileButton; 
        add: loadFileButton; 
        add: saveDbButton;
        yourself.
        
    ^ SpBoxLayout newTopToBottom
        spacing: 5;
        add: toolbarLayout expand: false;
        add: booksTable;
        add: statusBar expand: false;
        yourself
]

{ #category : 'accessing - model' }
LibraryPresenter >> initializePresenters [
    booksTable := self newTable.
    booksTable 
        addColumn: (SpStringTableColumn title: 'Назва' evaluated: [ :each | each title ]);
        addColumn: (SpStringTableColumn title: 'Рік' evaluated: [ :each | each year year asString ]);
        addColumn: (SpStringTableColumn title: 'Тип' evaluated: [ :each | each class name ]);
        addColumn: (SpStringTableColumn title: 'Обсяг' evaluated: [ :each | each totalVolume asString ]).
        
    addButton := self newButton label: 'Додати книгу'; iconName: #smallAdd.
    removeButton := self newButton label: 'Видалити'; iconName: #smallDelete.
    
    "Ініціалізація кнопок файлів/БД (Олег зміни це бо тут заглушки!!!)"
    saveFileButton := self newButton label: 'Зберегти у файл'; iconName: #smallSave.
    loadFileButton := self newButton label: 'Завантажити'; iconName: #smallOpen.
    saveDbButton := self newButton label: 'В базу даних'; iconName: #smallDatabase.
    
    statusBar := self newLabel.
    self updateUI.
]

{ #category : 'accessing - model' }
LibraryPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: (library name ifNil: [ 'Моя Бібліотека' ]);
        initialExtent: 800@500;
        windowIcon: (self iconNamed: #book).
]

{ #category : 'actions' }
LibraryPresenter >> openAddBookDialog [
    | dialog |
    dialog := BookDialogPresenter new.
    dialog openModal.
    dialog book ifNotNil: [ :newBook |
        library addBook: newBook.
        self updateUI.
    ].
]

{ #category : 'actions' }
LibraryPresenter >> removeSelectedBook [
    | selected |
    selected := booksTable selection selectedItem.
    selected ifNotNil: [
        library removeBook: selected.
        self updateUI.
    ].
]

{ #category : 'initialization' }
LibraryPresenter >> setModelBeforeInitialization: aLibrary [
    library := aLibrary.
]

{ #category : 'actions' }
LibraryPresenter >> updateUI [
    booksTable items: library books asArray.
    statusBar label: ('Всього примірників: {1} | Загальний обсяг друк. аркушів: {2}' 
        format: { library totalCopies . library totalPrintedSheets }).
]
