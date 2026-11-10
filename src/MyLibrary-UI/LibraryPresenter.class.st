Class {
	#name : 'LibraryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'library',
		'booksTable',
		'addButton',
		'removeButton',
		'viewButton',
		'searchAuthorButton',
		'searchYearButton',
		'resetButton',
		'replaceButton',
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
    viewButton action: [ self viewSelectedBook ].
    
    searchAuthorButton action: [ self searchByAuthor ].
    searchYearButton action: [ self searchByYear ].
    resetButton action: [ self updateUI ].
    
    replaceButton action: [ self reviewOldBooks ].
    saveFileButton action: [ self saveToFile ].
    loadFileButton action: [ self loadFromFile ].
    saveDbButton action: [ self saveToDatabase ].
]

{ #category : 'layout' }
LibraryPresenter >> defaultLayout [
    | topBar bottomBar |
    topBar := SpBoxLayout newLeftToRight
        spacing: 5;
        add: addButton; add: removeButton; add: viewButton;
        add: ' | ' asPresenter width: 20;
        add: searchAuthorButton; add: searchYearButton; add: resetButton;
        yourself.
        
    bottomBar := SpBoxLayout newLeftToRight
        spacing: 5;
        add: replaceButton;
        add: ' | ' asPresenter width: 20;
        add: saveFileButton; add: loadFileButton; add: saveDbButton;
        yourself.
        
    ^ SpBoxLayout newTopToBottom
        spacing: 5;
        add: topBar expand: false;
        add: booksTable;
        add: bottomBar expand: false;
        add: statusBar expand: false;
        yourself
]

{ #category : 'accessing - model' }
LibraryPresenter >> initializePresenters [
    booksTable := self newTable.
    booksTable 
        addColumn: (SpStringTableColumn title: 'Назва' evaluated: [ :each | each title ]);
        addColumn: (SpStringTableColumn title: 'Рік' evaluated: [ :each | each year year asString ]);
        addColumn: (SpStringTableColumn title: 'Автори' evaluated: [ :each | 
            String streamContents: [ :s | each printAuthorsOn: s ] ]);
        addColumn: (SpStringTableColumn title: 'Тип' evaluated: [ :each | each class name ]);
        addColumn: (SpStringTableColumn title: 'Обсяг' evaluated: [ :each | each totalVolume asString ]).
        
    "Верхня панель (керування та пошук)"
    addButton := self newButton label: 'Додати'; iconName: #smallAdd.
    removeButton := self newButton label: 'Видалити'; iconName: #smallDelete.
    viewButton := self newButton label: 'Переглянути'; iconName: #smallFind.
    
    searchAuthorButton := self newButton label: 'Пошук автора'; iconName: #smallSearch.
    searchYearButton := self newButton label: 'Пошук за роком'; iconName: #smallSearch.
    resetButton := self newButton label: 'Скинути фільтр'; iconName: #smallUpdate.
    
    "Нижня панель (дані)"
    replaceButton := self newButton label: 'Ревізія старих книг'; iconName: #smallQuestion.
    saveFileButton := self newButton label: 'Зберегти (STON)'; iconName: #smallSave.
    loadFileButton := self newButton label: 'Відкрити (STON)'; iconName: #smallOpen.
    saveDbButton := self newButton label: 'Зберегти в БД'; iconName: #smallDatabase.
    
    statusBar := self newLabel.
    self updateUI.
]

{ #category : 'accessing - model' }
LibraryPresenter >> initializeWindow: aWindowPresenter [
    aWindowPresenter
        title: (library name ifNil: [ 'Сучасна Бібліотека' ]);
        initialExtent: 950@550;
        windowIcon: (self iconNamed: #book).
]

{ #category : 'actions' }
LibraryPresenter >> loadFromFile [
    | fileRef |
    fileRef := UIManager default chooseExistingFileReference: 'Відкрити бібліотеку' extensions: #('ston') path: ''.
    fileRef ifNotNil: [
        library loadFromSTON: fileRef.
        self updateUI.
        UIManager default inform: 'Бібліотеку успішно завантажено!'.
    ].
]

{ #category : 'actions' }
LibraryPresenter >> openAddBookDialog [
    | dialog |
    dialog := BookDialogPresenter on: library. 
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

{ #category : 'actions' }
LibraryPresenter >> reviewOldBooks [
    | yearStr year |
    yearStr := UIManager default request: 'Введіть рік. Усі книги, видані ДО цього року, будуть запропоновані до списання:'.
    (yearStr isNil or: [ yearStr isEmpty ]) ifTrue: [ ^ self ].
    
    year := yearStr asInteger.
    year ifNotNil: [
        library reviewOldBooks: (Year year: year).
        self updateUI.
    ].
]

{ #category : 'actions' }
LibraryPresenter >> saveToDatabase [
    "Змінити тут!!"
    [ 
        library save. 
        UIManager default inform: 'Успішно синхронізовано з базою даних!' 
    ] on: Error do: [ :err | 
        UIManager default alert: 'Помилка підключення до БД (перевірте налаштування Voyage): ', err messageText 
    ].
]

{ #category : 'actions' }
LibraryPresenter >> saveToFile [
    | fileRef |
    fileRef := UIManager default chooseForSaveFileReference: 'Зберегти бібліотеку' extensions: #('ston') path: 'library.ston'.
    fileRef ifNotNil: [
        library saveToSTON: fileRef.
        UIManager default inform: 'Бібліотеку успішно збережено у файл!'.
    ].
]

{ #category : 'actions' }
LibraryPresenter >> searchByAuthor [
    | searchStr filtered |
    searchStr := UIManager default request: 'Введіть фрагмент імені або прізвища автора:'.
    (searchStr isNil or: [ searchStr isEmpty ]) ifTrue: [ ^ self ].
    
    filtered := library books select: [ :book | 
        book authors anySatisfy: [ :author | 
            author fullName includesSubstring: searchStr caseSensitive: false ] 
    ].
    
    booksTable items: filtered asArray.
    statusBar label: ('Пошук: знайдено {1} книг' format: { filtered size }).
]

{ #category : 'actions' }
LibraryPresenter >> searchByYear [
    | yearStr year filtered |
    yearStr := UIManager default request: 'Введіть рік видання (наприклад, 2024):'.
    (yearStr isNil or: [ yearStr isEmpty ]) ifTrue: [ ^ self ].
    
    year := yearStr asInteger.
    year ifNil: [ ^ UIManager default alert: 'Будь ласка, введіть коректне число!' ].
    
    filtered := library booksByYear: (Year year: year).
    booksTable items: filtered asArray.
    statusBar label: ('Пошук: знайдено {1} книг' format: { filtered size }).
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

{ #category : 'actions' }
LibraryPresenter >> viewSelectedBook [
    | selected |
    selected := booksTable selection selectedItem.
    selected ifNil: [ ^ UIManager default alert: 'Оберіть книгу для перегляду!' ].
    (BookInfoPresenter on: selected) open.
]
