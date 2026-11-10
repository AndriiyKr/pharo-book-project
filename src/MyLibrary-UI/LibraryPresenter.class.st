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
		'loadDbButton',
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
	 loadDbButton action: [ self loadFromDatabase ].

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
        add: saveFileButton; add: loadFileButton; add: saveDbButton; add: loadDbButton;
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
	 VORepository current ifNil: [ Library useInMemoryDatabase ].
	 library := Library new.
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
    saveFileButton := self newButton label: 'Зберегти у файл'; iconName: #smallSave.
    loadFileButton := self newButton label: 'Відкрити з файлу'; iconName: #smallOpen.
    saveDbButton := self newButton label: 'Зберегти в БД'; iconName: #smallDatabase.
	 loadDbButton := self newButton label: 'Відкрити з БД'; iconName: #smallOpen.
    
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
LibraryPresenter >> loadFromDatabase [
    | targetName loadedLib |
    
    targetName := UIManager default 
        request: 'Введіть назву бібліотеки для завантаження з БД:' 
        initialAnswer: (library name ifNil: [ 'Моя бібліотека' ]).
        
    targetName isEmptyOrNil ifTrue: [ ^ self ].
    
    "Шукаємо бібліотеку в пам'яті Voyage за введеною назвою"
    loadedLib := Library loadFromDatabase: targetName.
    
    loadedLib 
        ifNotNil: [ 
            library := loadedLib.
            self updateUI. 
            UIManager default inform: 'Бібліотеку "', targetName, '" успішно завантажено з БД!' ]
        ifNil: [ 
            UIManager default alert: 'Помилка: Бібліотеку з назвою "', targetName, '" не знайдено в БД!' ].
]

{ #category : 'actions' }
LibraryPresenter >> loadFromFile [
    | formatIndex fileName |
    "Запитуємо формат (без експорту тексту, бо ми його не зчитуємо)"
    formatIndex := UIManager default 
        chooseFrom: #('STON' 'StoreString') 
        title: 'Оберіть формат завантаження:'.
        
    formatIndex = 0 ifTrue: [ ^ self ]. 
    
    fileName := UIManager default request: 'Введіть ім''я файлу:' initialAnswer: 'library_data'.
    fileName isEmptyOrNil ifTrue: [ ^ self ].
    
    "Виконуємо завантаження залежно від вибору"
    formatIndex = 1 ifTrue: [ 
        library := Library new.
        library loadFromSTON: fileName, '.ston' ].
    formatIndex = 2 ifTrue: [ 
        library := Library loadFromStoreString: fileName, '.txt' ].
    
    self updateUI.
    UIManager default inform: 'Успішно завантажено!'.
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
    | targetName newLib |
    
    targetName := UIManager default 
        request: 'Введіть назву для збереження бібліотеки в БД:' 
        initialAnswer: (library name ifNil: [ 'Моя бібліотека' ]).
        
    targetName isEmptyOrNil ifTrue: [ ^ self ].
    
    "Якщо бібліотека ще не мала назви АБО назва не змінилася - просто оновлюємо поточну"
    (library name isNil or: [ library name = targetName ]) 
        ifTrue: [ 
            library name: targetName.
            library saveToDatabase.
        ] 
        ifFalse: [ 
            "Якщо користувач ввів НОВУ назву - робимо копію (Save As...)"
            newLib := Library new.
            newLib name: targetName.
            "Переносимо всі поточні книги у нову бібліотеку"
            library books do: [ :each | newLib addBook: each ].
            
            newLib saveToDatabase.
            library := newLib. "Тепер UI працює з цією новою бібліотекою"
        ].
    
    UIManager default inform: 'Бібліотеку "', targetName, '" успішно збережено в БД!'.
]

{ #category : 'actions' }
LibraryPresenter >> saveToFile [
    | formatIndex fileName |
    "Запитуємо формат"
    formatIndex := UIManager default 
        chooseFrom: #('STON' 'Звичайний текст (експорт)' 'StoreString') 
        title: 'Оберіть формат збереження:'.
        
    "Якщо користувач натиснув Cancel, припиняємо роботу"
    formatIndex = 0 ifTrue: [ ^ self ]. 
    
    "Запитуємо ім'я файлу"
    fileName := UIManager default request: 'Введіть ім''я файлу:' initialAnswer: 'library_data'.
    fileName isEmptyOrNil ifTrue: [ ^ self ].
    
    "Виконуємо збереження залежно від обраного варіанту"
    formatIndex = 1 ifTrue: [ library saveToSTON: fileName, '.ston' ].
    formatIndex = 2 ifTrue: [ library exportToText: fileName, '.txt' ].
    formatIndex = 3 ifTrue: [ library saveToStoreString: fileName, '.txt' ].
    
    UIManager default inform: 'Успішно збережено!'.
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
