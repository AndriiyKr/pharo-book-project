"
Тести для класу MultivolumeBook.

Перевіряємо:
 - томи: геттер (копія), сеттер volumes: (валідація, атомарність, унікальність номерів);
 - зміну «на місці»: addVolume: / removeVolume:;
 - оператори + і - (додають/видаляють том у самому багатотомнику і повертають його);
 - totalVolume, volumeCount, printedSheets;
 - порівняння (=, hash, <, сортування) і копіювання (postCopy);
 - створення конструктором класу та друк (printVolumeInfoOn:, printString).

Тести не залежать від виправлень у Book, Author і Publisher: використовуються лише
екземпляри Author, Publisher і Year, які Book приймає в своєму поточному вигляді.
"
Class {
	#name : 'MultivolumeBookTest',
	#superclass : 'TestCase',
	#instVars : [
		'book',
		'volumeOne',
		'volumeTwo',
		'volumeThree',
		'author',
		'publisher'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'helpers' }
MultivolumeBookTest >> assertError: aBlock messageIncludes: aString [
    "Перевіряє, що блок кидає Error, а текст помилки містить заданий фрагмент"
    self
        should: aBlock
        raise: Error
        withExceptionDo: [ :e | self assert: (e messageText includesSubstring: aString) ]
]

{ #category : 'helpers' }
MultivolumeBookTest >> fillBook [
    "Додає в book усі три томи (змінюючи book)"
    book
        addVolume: volumeOne;
        addVolume: volumeTwo;
        addVolume: volumeThree
]

{ #category : 'helpers' }
MultivolumeBookTest >> newBookWithVolumes: aCollection [
    "Створює повністю заповнений багатотомник (автор, назва, видавництво, рік 1976) з вказаними томами.
     Автори й видавництва передаються як OrderedCollection, бо Book зберігає передану колекцію як є,
     а масив (Array) не підтримує додавання (addAuthor:) і не дорівнює OrderedCollection"
    ^ MultivolumeBook
        authors: (OrderedCollection with: author)
        title: 'Зібрання творів'
        publishers: (OrderedCollection with: publisher)
        year: (Year year: 1976)
        volumes: aCollection
]

{ #category : 'helpers' }
MultivolumeBookTest >> printedVolumeInfoOf: aBook [
    "Повертає текст, який друкує printVolumeInfoOn:"
    ^ String streamContents: [ :stream | aBook printVolumeInfoOn: stream ]
]

{ #category : 'running' }
MultivolumeBookTest >> setUp [
    "Готує порожній багатотомник, три окремі томи (100 + 200 + 150 = 450 сторінок), автора і видавництво"
    super setUp.
    book := MultivolumeBook new.
    volumeOne := Volume number: 1 pages: 100 title: 'Перший'.
    volumeTwo := Volume number: 2 pages: 200 title: 'Другий'.
    volumeThree := Volume number: 3 pages: 150 title: 'Третій'.
    author := Author
        firstName: 'Іван'
        lastName: 'Франко'
        birthDate: (Date year: 1856 month: 8 day: 27)
        city: 'Нагуєвичі'.
    publisher := Publisher name: 'Наукова думка' city: 'Київ' foundationYear: (Year year: 1922)
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeRejectsDuplicateNumber [
    "Том з уже наявним номером додати не можна, навіть якщо він інший об'єкт"
    book addVolume: volumeOne.
    self
        assertError: [ book addVolume: (Volume number: 1 pages: 5 title: 'Дубль') ]
        messageIncludes: 'таким номером'.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeRejectsNil [
    "addVolume: відхиляє nil"
    self should: [ book addVolume: nil ] raise: Error.
    self assert: book volumes isEmpty
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeRejectsNumber [
    "addVolume: відхиляє число (на відміну від Volume >> +, багатотомник не приймає сторінки)"
    self should: [ book addVolume: 5 ] raise: Error.
    self assert: book volumes isEmpty
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeRejectsSameVolumeTwice [
    "Один і той самий том не можна додати двічі"
    book addVolume: volumeOne.
    self should: [ book addVolume: volumeOne ] raise: Error.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeRejectsString [
    "addVolume: відхиляє рядок, і колекція томів лишається порожньою"
    self assertError: [ book addVolume: 'не том' ] messageIncludes: 'Volume'.
    self assert: book volumes isEmpty
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeReturnsAddedVolume [
    "addVolume: повертає доданий том (як add: у колекціях)"
    self assert: (book addVolume: volumeOne) identicalTo: volumeOne
]

{ #category : 'tests - addVolume' }
MultivolumeBookTest >> testAddVolumeStoresVolume [
    "addVolume: додає том у багатотомник"
    book addVolume: volumeOne.
    self assert: book volumeCount equals: 1.
    self assert: book volumes first identicalTo: volumeOne
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionary [
    "Багатотомник створюється зі словника: назва, рік, автори, видавництва і томи (екземпляри Volume)"
    | dict created |
    dict := Dictionary new.
    dict at: 'title' put: 'Зібрання творів'; at: 'year' put: 1976; at: 'authors' put: { author }; at: 'publishers' put: { publisher }; at: 'volumes' put: { volumeOne. volumeTwo }.
    created := MultivolumeBook bookFromDictionary: dict.
    self assert: created class equals: MultivolumeBook.
    self assert: created title equals: 'Зібрання творів'.
    self assert: created year year equals: 1976.
    self assert: created authors asArray equals: { author }.
    self assert: created publishers asArray equals: { publisher }.
    self assert: created totalVolume equals: 300
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryRejectsDuplicateVolumeNumbers [
    "Томи з однаковими номерами у словнику відхиляються (унікальність номерів)"
    | dict |
    dict := Dictionary new.
    dict at: 'volumes' put: { volumeOne. (Volume number: 1 pages: 5 title: 'Дубль') }.
    self assertError: [ MultivolumeBook bookFromDictionary: dict ] messageIncludes: 'однаковими номерами'
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryRejectsInvalidVolume [
    "Елемент списку томів, що не є Volume чи словником, відхиляється з повідомленням про клас Volume"
    | dict |
    dict := Dictionary new.
    dict at: 'volumes' put: { 'не том' }.
    self assertError: [ MultivolumeBook bookFromDictionary: dict ] messageIncludes: 'Volume'
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryResultCanBeExtended [
    "Книга зі словника повністю працездатна: до неї можна додавати томи та авторів"
    | created |
    created := MultivolumeBook bookFromDictionary: Dictionary new.
    created + volumeOne.
    created addAuthor: author.
    self assert: created volumeCount equals: 1.
    self assert: created authors size equals: 1
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryWithInvalidYearFails [
    "Рядок, що не є числом, не можна перетворити на рік - контрольована помилка"
    | dict |
    dict := Dictionary new.
    dict at: 'year' put: 'давно'.
    self assertError: [ MultivolumeBook bookFromDictionary: dict ] messageIncludes: 'рік'
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryWithStringYear [
    "Рік у словнику може бути рядком з числом"
    | dict |
    dict := Dictionary new.
    dict at: 'year' put: '1976'.
    self assert: (MultivolumeBook bookFromDictionary: dict) year year equals: 1976
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryWithVolumeDictionaries [
    "Томи у словнику можуть бути вкладеними словниками (як у даних із файлу)"
    | v1 v2 dict created |
    v1 := Dictionary new.
    v1 at: 'volumeNumber' put: 1; at: 'pageCount' put: 100; at: 'titleVolume' put: 'Перший'.
    v2 := Dictionary new.
    v2 at: 'volumeNumber' put: 2; at: 'pageCount' put: 200; at: 'titleVolume' put: 'Другий'.
    dict := Dictionary new.
    dict at: 'volumes' put: { v1. v2 }.
    created := MultivolumeBook bookFromDictionary: dict.
    self assert: created volumeCount equals: 2.
    self assert: created totalVolume equals: 300.
    self assert: created volumes first equals: volumeOne
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromDictionaryWithYearObject [
    "Рік у словнику може бути готовим екземпляром Year"
    | dict |
    dict := Dictionary new.
    dict at: 'year' put: (Year year: 1999).
    self assert: (MultivolumeBook bookFromDictionary: dict) year year equals: 1999
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testBookFromEmptyDictionaryUsesDefaults [
    "Порожній словник дає книгу зі значеннями за замовчуванням: назва, поточний рік, автор і видавництво за замовчуванням, без томів"
    | created |
    created := MultivolumeBook bookFromDictionary: Dictionary new.
    self assert: created title equals: Book defaultTitle.
    self assert: created year year equals: Book defaultYear year.
    self assert: created authors size equals: 1.
    self assert: created authors first lastName equals: Author defaultLastName.
    self assert: created publishers size equals: 1.
    self assert: created publishers first name equals: Publisher defaultName.
    self assert: created volumes isEmpty
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testBookIsNotEqualToOtherObjects [
    "Книга не дорівнює nil чи рядку (і порівняння не викликає помилки)"
    self deny: book = nil.
    self deny: book = 'книга'
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testBooksOfSameVolumeAreOrderedEquivalentButNotEqual [
    "Книги однакового обсягу не менші одна за одну (<=, >= істинні), але не рівні (=): порівняння за обсягом і рівність за даними - різні відношення"
    | other |
    other := MultivolumeBook new.
    other addVolume: (Volume number: 1 pages: 100 title: 'Інший').
    book addVolume: volumeOne.
    self deny: book < other.
    self deny: other < book.
    self assert: book <= other.
    self assert: book >= other.
    self deny: book = other
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testBooksWithDifferentTitlesAreNotEqual [
    "Книги з однаковими томами, але різною назвою не рівні"
    | first second |
    first := self newBookWithVolumes: { volumeOne }.
    second := self newBookWithVolumes: { volumeOne }.
    second title: 'Інша назва'.
    self deny: first = second
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testBooksWithDifferentVolumesAreNotEqual [
    "Книги з однаковими метаданими, але різними томами не рівні (= враховує томи)"
    | first second |
    first := self newBookWithVolumes: { volumeOne. volumeTwo }.
    second := self newBookWithVolumes: { volumeOne }.
    self deny: first = second
]

{ #category : 'tests - creation' }
MultivolumeBookTest >> testClassSideConstructor [
    "Конструктор класу створює багатотомник одразу з автором, назвою, видавництвом, роком і томами"
    | created |
    created := self newBookWithVolumes: { volumeOne. volumeTwo }.
    self assert: created class equals: MultivolumeBook.
    self assert: created title equals: 'Зібрання творів'.
    self assert: created year year equals: 1976.
    self assert: created authors asArray equals: { author }.
    self assert: created publishers asArray equals: { publisher }.
    self assert: created totalVolume equals: 300
]

{ #category : 'tests - copying' }
MultivolumeBookTest >> testCopyIsEqualToOriginal [
    "Копія багатотомника дорівнює оригіналу за значенням, але є іншим об'єктом"
    | original |
    original := self newBookWithVolumes: { volumeOne. volumeTwo }.
    self assert: original copy equals: original.
    self deny: original copy == original
]

{ #category : 'tests - copying' }
MultivolumeBookTest >> testCopyIsIndependentOfOriginal [
    "Зміни копії (томи, автори) не торкаються оригіналу: postCopy дає копії власні колекції"
    | original copy |
    original := self newBookWithVolumes: { volumeOne }.
    copy := original copy.
    copy addVolume: volumeTwo.
    copy addAuthor: (Author firstName: 'Леся' lastName: 'Українка' birthDate: (Date year: 1871 month: 2 day: 25) city: 'Новоград-Волинський').
    self assert: original volumeCount equals: 1.
    self assert: original authors size equals: 1.
    self assert: copy volumeCount equals: 2.
    self assert: copy authors size equals: 2
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testEqualBooksWithEqualVolumes [
    "Книги з однаковими метаданими й рівними (за значенням) томами рівні і мають однаковий hash"
    | first second |
    first := self newBookWithVolumes: { volumeOne. volumeTwo }.
    second := self newBookWithVolumes: { volumeOne copy. volumeTwo copy }.
    self assert: first equals: second.
    self assert: first hash equals: second hash
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testFailedVolumesSetterKeepsPreviousState [
    "Валідація виконується ДО присвоєння: при помилці старі томи не втрачаються"
    book volumes: { volumeOne }.
    self should: [ book volumes: { volumeTwo. 42 } ] raise: Error.
    self assert: book volumeCount equals: 1.
    self assert: book volumes first identicalTo: volumeOne
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testLessThanComparesTotalVolume [
    "Книги порівнюються за обсягом: 100 стор. < 300 стор.; працюють також >, <=, max:"
    | small big |
    small := self newBookWithVolumes: { volumeOne }.
    big := self newBookWithVolumes: { volumeOne. volumeTwo }.
    self assert: small < big.
    self deny: big < small.
    self assert: big > small.
    self assert: small <= big.
    self deny: big <= small.
    self assert: (small max: big) identicalTo: big
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testMinusAbsentVolumeRaisesError [
    "Оператор - з відсутнім томом дає помилку, оригінал не змінюється"
    book addVolume: volumeOne.
    self assertError: [ book - volumeTwo ] messageIncludes: 'немає'.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testMinusFromEmptyBookRaisesError [
    "Оператор - на порожньому багатотомнику: том не знайдено, тому виникає помилка"
    self should: [ book - volumeOne ] raise: Error
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testMinusRemovesVolumeFromReceiver [
    "Оператор - видаляє том із цього самого багатотомника, інші томи лишаються"
    self fillBook.
    book - volumeTwo.
    self assert: book volumeCount equals: 2.
    self deny: (book volumes includes: volumeTwo)
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testMinusReturnsReceiver [
    "Оператор - повертає сам багатотомник (self)"
    book addVolume: volumeOne.
    self assert: (book - volumeOne) identicalTo: book
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testPlusAddsVolumeToReceiver [
    "Оператор + додає том у цей самий багатотомник"
    book + volumeOne.
    self assert: book volumeCount equals: 1.
    self assert: book volumes first identicalTo: volumeOne
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testPlusChaining [
    "Оператори можна ланцюжити; порядок томів зберігається, обсяг 100 + 200 + 150 = 450"
    book + volumeOne + volumeTwo + volumeThree.
    self
        assert: book volumes asArray
        equals: { volumeOne. volumeTwo. volumeThree }.
    self assert: book totalVolume equals: 450
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testPlusRejectsDuplicateNumber [
    "Оператор + відхиляє том з уже наявним номером"
    book addVolume: volumeOne.
    self should: [ book + (Volume number: 1 pages: 7 title: 'Дубль') ] raise: Error.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testPlusRejectsString [
    "Оператор + відхиляє не-Volume, оригінал лишається порожнім"
    self assertError: [ book + 'не том' ] messageIncludes: 'Volume'.
    self assert: book volumes isEmpty
]

{ #category : 'tests - operators' }
MultivolumeBookTest >> testPlusReturnsReceiver [
    "Оператор + повертає сам багатотомник (self)"
    self assert: (book + volumeOne) identicalTo: book
]

{ #category : 'tests - printing' }
MultivolumeBookTest >> testPrintString [
    "Повний рядок: назва, автори, інформація про томи, рік, видавництва (через кому)"
    self
        assert: (self newBookWithVolumes: { volumeOne. volumeTwo. volumeThree }) printString
        equals: 'Зібрання творів, Іван Франко, 3 томів (загалом 450 стор., 15 друк. арк.), 1976, Наукова думка'
]

{ #category : 'tests - printing' }
MultivolumeBookTest >> testPrintStringOfEmptyBook [
    "Порожній багатотомник друкується зі значеннями за замовчуванням (назва, автор, поточний рік, видавництво)"
    self
        assert: book printString
        equals: Book defaultTitle, ', ', Author defaultAuthor fullName,
            ', 0 томів (загалом 0 стор., 0 друк. арк.), ',
            Book defaultYear year printString, ', ', Publisher defaultPublisher name
]

{ #category : 'tests - printing' }
MultivolumeBookTest >> testPrintStringWithAuthorAndPublisher [
    "Книга без заданого року друкує поточний рік; автор і видавництво замінюють значення за замовчуванням"
    book addAuthor: author.
    book addPublisher: publisher.
    book addVolume: volumeOne.
    self
        assert: book printString
        equals: 'Без назви, Іван Франко, 1 томів (загалом 100 стор., 4 друк. арк.), ',
            Book defaultYear year printString, ', Наукова думка'
]

{ #category : 'tests - printing' }
MultivolumeBookTest >> testPrintVolumeInfoOnEmptyBook [
    "Формат: '<кількість> томів (загалом <стор.> стор., <арк.> друк. арк.)' для порожнього багатотомника"
    self
        assert: (self printedVolumeInfoOf: book)
        equals: '0 томів (загалом 0 стор., 0 друк. арк.)'
]

{ #category : 'tests - printing' }
MultivolumeBookTest >> testPrintVolumeInfoOnFilledBook [
    "Для трьох томів по 450 сторінок разом: 450 / 32 = 14.06, округлено вгору до 15 друкованих аркушів"
    self fillBook.
    self
        assert: (self printedVolumeInfoOf: book)
        equals: '3 томів (загалом 450 стор., 15 друк. арк.)'
]

{ #category : 'tests - total volume' }
MultivolumeBookTest >> testPrintedSheetsRoundsUp [
    "printedSheets = totalVolume / 32, округлено вгору: 0 стор. - 0 арк., 32 стор. - 1 арк., 33 стор. - 2 арк."
    self assert: book printedSheets equals: 0.
    book addVolume: (Volume number: 1 pages: 32 title: 'А').
    self assert: book printedSheets equals: 1.
    book addVolume: (Volume number: 2 pages: 1 title: 'Б').
    self assert: book printedSheets equals: 2
]

{ #category : 'tests - removeVolume' }
MultivolumeBookTest >> testRemoveAbsentVolumeRaisesError [
    "Видалення тому, якого немає, - помилка; наявні томи не постраждали"
    book addVolume: volumeOne.
    self assertError: [ book removeVolume: volumeTwo ] messageIncludes: 'немає'.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - removeVolume' }
MultivolumeBookTest >> testRemoveLastVolumeLeavesBookEmpty [
    "Після видалення єдиного тому багатотомник порожній, а totalVolume дорівнює 0"
    book addVolume: volumeOne.
    book removeVolume: volumeOne.
    self assert: book volumes isEmpty.
    self assert: book totalVolume equals: 0
]

{ #category : 'tests - removeVolume' }
MultivolumeBookTest >> testRemoveVolumeFromEmptyBookRaisesError [
    "Видалення з порожнього багатотомника: том не знайдено, тому виникає помилка (блок ifAbsent:)"
    self should: [ book removeVolume: volumeOne ] raise: Error
]

{ #category : 'tests - removeVolume' }
MultivolumeBookTest >> testRemoveVolumeRemovesIt [
    "removeVolume: видаляє вказаний том, інші томи лишаються"
    self fillBook.
    book removeVolume: volumeOne.
    self assert: book volumeCount equals: 2.
    self deny: (book volumes includes: volumeOne).
    self assert: (book volumes includes: volumeTwo)
]

{ #category : 'tests - removeVolume' }
MultivolumeBookTest >> testRemoveVolumeUsesValueEquality [
    "Том видаляється і тоді, коли передано ІНШИЙ об'єкт з тими самими даними"
    book addVolume: volumeOne.
    book removeVolume: (Volume number: 1 pages: 100 title: 'Перший').
    self assert: book volumes isEmpty
]

{ #category : 'tests - comparing' }
MultivolumeBookTest >> testSortingByVolume [
    "asSortedCollection впорядковує книги за обсягом (найменша перша)"
    | small big sorted |
    small := self newBookWithVolumes: { volumeOne }.
    big := self newBookWithVolumes: { volumeOne. volumeTwo }.
    sorted := { big. small } asSortedCollection.
    self assert: sorted first identicalTo: small.
    self assert: sorted last identicalTo: big
]

{ #category : 'tests - total volume' }
MultivolumeBookTest >> testTotalVolumeAfterRemoval [
    "Після видалення тому totalVolume перераховується без нього (450 - 200 = 250)"
    self fillBook.
    book removeVolume: volumeTwo.
    self assert: book totalVolume equals: 250
]

{ #category : 'tests - total volume' }
MultivolumeBookTest >> testTotalVolumeOfEmptyBookIsZero [
    "Загальна кількість сторінок порожнього багатотомника дорівнює 0"
    self assert: book totalVolume equals: 0
]

{ #category : 'tests - total volume' }
MultivolumeBookTest >> testTotalVolumeOfSingleVolume [
    "Для одного тому totalVolume дорівнює його pageCount (200)"
    book addVolume: volumeTwo.
    self assert: book totalVolume equals: 200
]

{ #category : 'tests - total volume' }
MultivolumeBookTest >> testTotalVolumeReflectsChangesInsideVolume [
    "Багатотомник зберігає посилання на томи, тому зміна тому через pageCount: одразу видна в totalVolume"
    book addVolume: volumeOne.
    book addVolume: volumeTwo.
    volumeOne pageCount: 125.
    self assert: book totalVolume equals: 325
]

{ #category : 'tests - total volume' }
MultivolumeBookTest >> testTotalVolumeSumsAllPages [
    "totalVolume складає сторінки всіх томів (100 + 200 + 150 = 450)"
    self fillBook.
    self assert: book totalVolume equals: 450
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesGetterReturnsCopy [
    "Зміна колекції, отриманої через volumes, не впливає на багатотомник (захист від обходу валідації)"
    book addVolume: volumeOne.
    book volumes add: volumeTwo.
    book volumes removeAll.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesIsEmptyByDefault [
    "Новий багатотомник не містить томів; volumes повертає OrderedCollection"
    self assert: book volumes isEmpty.
    self assert: book volumes class equals: OrderedCollection.
    self assert: book volumeCount equals: 0
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterAcceptsEmptyCollection [
    "volumes: приймає порожню колекцію й очищає багатотомник"
    book volumes: { volumeOne }.
    book volumes: #().
    self assert: book volumes isEmpty
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterConvertsArrayToOrderedCollection [
    "Передали Array - всередині OrderedCollection, тож після цього можна додавати нові томи"
    book volumes: { volumeOne }.
    book addVolume: volumeTwo.
    self assert: book volumeCount equals: 2
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterDoesNotAliasArgument [
    "Після volumes: зміна переданої колекції ззовні не впливає на багатотомник"
    | source |
    source := OrderedCollection with: volumeOne.
    book volumes: source.
    source add: volumeTwo.
    self assert: book volumeCount equals: 1
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterPreservesOrder [
    "volumes: зберігає порядок томів такий самий, як у переданій колекції"
    book volumes: { volumeThree. volumeOne. volumeTwo }.
    self
        assert: book volumes asArray
        equals: { volumeThree. volumeOne. volumeTwo }
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterRejectsDuplicateNumbers [
    "У колекції не може бути двох томів з однаковим номером"
    self
        assertError: [ book volumes: { volumeOne. (Volume number: 1 pages: 5 title: 'Дубль') } ]
        messageIncludes: 'однаковими номерами'
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterRejectsNonVolumeElements [
    "Колекція з об'єктом не того класу відхиляється з повідомленням про клас Volume"
    self
        assertError: [ book volumes: { volumeOne. 'не том' } ]
        messageIncludes: 'Volume'
]

{ #category : 'tests - volumes accessor' }
MultivolumeBookTest >> testVolumesSetterStoresVolumes [
    "volumes: зберігає передані томи, і вони доступні через геттер"
    book volumes: { volumeOne. volumeTwo }.
    self assert: book volumeCount equals: 2.
    self assert: (book volumes includes: volumeOne).
    self assert: (book volumes includes: volumeTwo)
]
