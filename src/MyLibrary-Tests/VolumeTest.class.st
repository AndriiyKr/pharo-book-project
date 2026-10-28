"
Тести для класу Volume (том багатотомного видання).

Перевіряємо: значення за замовчуванням, конструктор, валідацію сеттерів,
арифметику (+ і - змінюють том і повертають його самого), порівняння (=, hash, <) і printOn:.
"
Class {
	#name : 'VolumeTest',
	#superclass : 'TestCase',
	#instVars : [
		'volume'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'helpers' }
VolumeTest >> assertError: aBlock messageIncludes: aString [
    "Перевіряє, що блок кидає Error, а текст помилки містить заданий фрагмент"
    self
        should: aBlock
        raise: Error
        withExceptionDo: [ :e | self assert: (e messageText includesSubstring: aString) ]
]

{ #category : 'running' }
VolumeTest >> setUp [
    "Готує типовий том (номер 2, 300 сторінок), який використовується в більшості тестів"
    super setUp.
    volume := Volume number: 2 pages: 300 title: 'Друга частина'
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testArithmeticChaining [
    "Оператори можна ланцюжити: 300 + 20 - 70 = 250"
    volume + 20 - 70.
    self assert: volume pageCount equals: 250
]

{ #category : 'tests - defaults' }
VolumeTest >> testClassSideDefaults [
    "Класові константи мають очікувані значення"
    self assert: Volume defaultPageCount equals: 1.
    self assert: Volume defaultVolumeNumber equals: 1.
    self assert: Volume defaultTitle equals: 'Без назви'
]

{ #category : 'tests - comparing' }
VolumeTest >> testCopyIsEqualButNotIdentical [
    "Копія тому дорівнює оригіналу за значенням, але є іншим об'єктом"
    | copy |
    copy := volume copy.
    self assert: copy equals: volume.
    self deny: copy == volume
]

{ #category : 'tests - defaults' }
VolumeTest >> testDefaultValuesOfNewVolume [
    "Том, створений через new, отримує значення за замовчуванням у initialize"
    | empty |
    empty := Volume new.
    self assert: empty volumeNumber equals: Volume defaultVolumeNumber.
    self assert: empty pageCount equals: Volume defaultPageCount.
    self assert: empty titleVolume equals: Volume defaultTitle
]

{ #category : 'tests - defaults' }
VolumeTest >> testEmptyTitleFallsBackToDefault [
    "Порожня назва замінюється назвою за замовчуванням"
    volume titleVolume: ''.
    self assert: volume titleVolume equals: Volume defaultTitle
]

{ #category : 'tests - comparing' }
VolumeTest >> testEqualityOfVolumesWithSameData [
    "Томи з однаковими номером, назвою та кількістю сторінок рівні і мають однаковий hash"
    | same |
    same := Volume number: 2 pages: 300 title: 'Друга частина'.
    self assert: volume equals: same.
    self assert: volume hash equals: same hash
]

{ #category : 'tests - validation' }
VolumeTest >> testFailedPageCountSetterKeepsOldValue [
    "Після невдалої спроби встановлення стан об'єкта не змінюється"
    self should: [ volume pageCount: -1 ] raise: Error.
    self assert: volume pageCount equals: 300
]

{ #category : 'tests - creation' }
VolumeTest >> testInstanceCreation [
    "Конструктор number:pages:title: встановлює всі три поля"
    self assert: volume volumeNumber equals: 2.
    self assert: volume pageCount equals: 300.
    self assert: volume titleVolume equals: 'Друга частина'
]

{ #category : 'tests - creation' }
VolumeTest >> testInstanceCreationWithInvalidNumberFails [
    "Конструктор з від'ємним номером тому завершується помилкою"
    self should: [ Volume number: -1 pages: 10 title: 'X' ] raise: Error
]

{ #category : 'tests - creation' }
VolumeTest >> testInstanceCreationWithInvalidPagesFails [
    "Конструктор використовує сеттери, тож нульова кількість сторінок відхиляється"
    self should: [ Volume number: 1 pages: 0 title: 'X' ] raise: Error
]

{ #category : 'tests - comparing' }
VolumeTest >> testLessThanComparesPageCount [
    "Оператор < порівнює томи за кількістю сторінок"
    | small sameSize |
    small := Volume number: 1 pages: 10 title: 'Малий'.
    sameSize := Volume number: 9 pages: 300 title: 'Інший'.
    self assert: small < volume.
    self deny: volume < small.
    self deny: volume < sameSize.
    self deny: sameSize < volume
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testMinusDecreasesPageCount [
    "Оператор - зменшує кількість сторінок цього тому (300 - 100 = 200)"
    volume - 100.
    self assert: volume pageCount equals: 200
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testMinusExactlyToDefaultPageCount [
    "Гранична ситуація: результат рівно дорівнює мінімуму (300 - 299 = 1)"
    volume - 299.
    self assert: volume pageCount equals: 1
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testMinusNeverGoesBelowDefaultPageCount [
    "Віднімання більше, ніж є сторінок, обмежується мінімумом - defaultPageCount"
    volume - 10000.
    self assert: volume pageCount equals: Volume defaultPageCount
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testMinusReturnsReceiver [
    "Оператор - повертає сам том (self)"
    self assert: (volume - 10) identicalTo: volume
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testMinusZeroKeepsPageCount [
    "Віднімання нуля не змінює кількість сторінок"
    volume - 0.
    self assert: volume pageCount equals: 300
]

{ #category : 'tests - defaults' }
VolumeTest >> testNilTitleFallsBackToDefault [
    "Назва nil замінюється назвою за замовчуванням"
    volume titleVolume: nil.
    self assert: volume titleVolume equals: Volume defaultTitle
]

{ #category : 'tests - validation' }
VolumeTest >> testPageCountSetterAcceptsPositive [
    "pageCount: приймає додатні значення, зокрема мінімальне (1) і велике (1000)"
    volume pageCount: 1.
    self assert: volume pageCount equals: 1.
    volume pageCount: 1000.
    self assert: volume pageCount equals: 1000
]

{ #category : 'tests - validation' }
VolumeTest >> testPageCountSetterRejectsNegative [
    "pageCount: відхиляє від'ємну кількість сторінок"
    self should: [ volume pageCount: -5 ] raise: Error
]

{ #category : 'tests - validation' }
VolumeTest >> testPageCountSetterRejectsNonInteger [
    "pageCount: відхиляє не цілі значення (nil, дріб, рядок) контрольованою помилкою, а не doesNotUnderstand"
    self assertError: [ volume pageCount: nil ] messageIncludes: 'Кількість сторінок'.
    self assertError: [ volume pageCount: 2.5 ] messageIncludes: 'Кількість сторінок'.
    self assertError: [ volume pageCount: '10' ] messageIncludes: 'Кількість сторінок'
]

{ #category : 'tests - validation' }
VolumeTest >> testPageCountSetterRejectsZero [
    "Нуль - недопустима кількість сторінок; повідомлення згадує кількість сторінок"
    self assertError: [ volume pageCount: 0 ] messageIncludes: 'Кількість сторінок'
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testPlusIncreasesPageCount [
    "Оператор + збільшує кількість сторінок цього тому (300 + 50 = 350)"
    volume + 50.
    self assert: volume pageCount equals: 350
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testPlusKeepsNumberAndTitle [
    "Оператор + змінює лише кількість сторінок, номер і назва лишаються"
    volume + 1.
    self assert: volume volumeNumber equals: 2.
    self assert: volume titleVolume equals: 'Друга частина'
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testPlusOnDefaultVolume [
    "+ працює і для тому зі значенням за замовчуванням (1 + 9 = 10)"
    | empty |
    empty := Volume new.
    empty + 9.
    self assert: empty pageCount equals: 10
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testPlusRejectsNonPositiveResult [
    "Якщо результат + не додатний (300 + -300 = 0), спрацьовує та сама валідація, що й у pageCount:"
    self assertError: [ volume + -300 ] messageIncludes: 'Кількість сторінок'.
    self assertError: [ volume + -1000 ] messageIncludes: 'Кількість сторінок'.
    self assert: volume pageCount equals: 300
]

{ #category : 'tests - arithmetic' }
VolumeTest >> testPlusReturnsReceiver [
    "Оператор + повертає сам том (self), а не копію"
    self assert: (volume + 10) identicalTo: volume
]

{ #category : 'tests - printing' }
VolumeTest >> testPrintString [
    "Рядкове представлення: стандартний префікс + інформація про том"
    self assert: (volume printString beginsWith: 'a Volume').
    self assert: (volume printString endsWith: ' (Том 2: Друга частина, 300 стор.)')
]

{ #category : 'tests - printing' }
VolumeTest >> testPrintStringOfDefaultVolume [
    "Для тому зі значеннями за замовчуванням друкуються ці значення"
    self assert: (Volume new printString endsWith: ' (Том 1: Без назви, 1 стор.)')
]

{ #category : 'tests - printing' }
VolumeTest >> testPrintStringReflectsChanges [
    "printOn: використовує поточний стан тому, а не закешоване значення"
    volume pageCount: 305.
    self assert: (volume printString includesSubstring: '305 стор.')
]

{ #category : 'tests - creation' }
VolumeTest >> testVolumeFromDictionary [
    "Том створюється зі словника з ключами volumeNumber, pageCount, titleVolume"
    | dict created |
    dict := Dictionary new.
    dict at: 'volumeNumber' put: 4; at: 'pageCount' put: 250; at: 'titleVolume' put: 'Четвертий'.
    created := Volume volumeFromDictionary: dict.
    self assert: created volumeNumber equals: 4.
    self assert: created pageCount equals: 250.
    self assert: created titleVolume equals: 'Четвертий'
]

{ #category : 'tests - creation' }
VolumeTest >> testVolumeFromDictionaryAcceptsStringNumbers [
    "Числа у словнику можуть бути рядками (наприклад, прочитаними з файлу)"
    | dict created |
    dict := Dictionary new.
    dict at: 'volumeNumber' put: '3'; at: 'pageCount' put: '120'.
    created := Volume volumeFromDictionary: dict.
    self assert: created volumeNumber equals: 3.
    self assert: created pageCount equals: 120
]

{ #category : 'tests - creation' }
VolumeTest >> testVolumeFromDictionaryRejectsInvalidValues [
    "Некоректні значення (нуль, нечисловий рядок, від'ємний номер) відхиляються сеттерами"
    | dict |
    dict := Dictionary new.
    dict at: 'pageCount' put: 0.
    self assertError: [ Volume volumeFromDictionary: dict ] messageIncludes: 'Кількість сторінок'.
    dict at: 'pageCount' put: 'багато'.
    self assertError: [ Volume volumeFromDictionary: dict ] messageIncludes: 'Кількість сторінок'.
    dict := Dictionary new.
    dict at: 'volumeNumber' put: -1.
    self assertError: [ Volume volumeFromDictionary: dict ] messageIncludes: 'Номер тому'
]

{ #category : 'tests - creation' }
VolumeTest >> testVolumeFromDictionaryTreatsEmptyStringsAsDefaults [
    "Порожні рядки у словнику (як у незаповненій формі) замінюються значеннями за замовчуванням"
    | dict created |
    dict := Dictionary new.
    dict at: 'volumeNumber' put: ''; at: 'pageCount' put: ''; at: 'titleVolume' put: ''.
    created := Volume volumeFromDictionary: dict.
    self assert: created volumeNumber equals: Volume defaultVolumeNumber.
    self assert: created pageCount equals: Volume defaultPageCount.
    self assert: created titleVolume equals: Volume defaultTitle
]

{ #category : 'tests - creation' }
VolumeTest >> testVolumeFromEmptyDictionaryUsesDefaults [
    "Порожній словник дає том зі значеннями за замовчуванням"
    | created |
    created := Volume volumeFromDictionary: Dictionary new.
    self assert: created volumeNumber equals: Volume defaultVolumeNumber.
    self assert: created pageCount equals: Volume defaultPageCount.
    self assert: created titleVolume equals: Volume defaultTitle
]

{ #category : 'tests - comparing' }
VolumeTest >> testVolumeIsNotEqualToOtherObjects [
    "Том не дорівнює nil, рядку чи числу (і порівняння не викликає помилки)"
    self deny: volume = nil.
    self deny: volume = 'Том'.
    self deny: volume = 300
]

{ #category : 'tests - validation' }
VolumeTest >> testVolumeNumberSetterAcceptsPositive [
    "volumeNumber: приймає додатний номер і зберігає його"
    volume volumeNumber: 7.
    self assert: volume volumeNumber equals: 7
]

{ #category : 'tests - validation' }
VolumeTest >> testVolumeNumberSetterRejectsNegativeAndKeepsOldValue [
    "volumeNumber: відхиляє від'ємний номер, а попереднє значення (2) лишається"
    self should: [ volume volumeNumber: -3 ] raise: Error.
    self assert: volume volumeNumber equals: 2
]

{ #category : 'tests - validation' }
VolumeTest >> testVolumeNumberSetterRejectsNonInteger [
    "volumeNumber: відхиляє nil і нецілі значення контрольованою помилкою"
    self assertError: [ volume volumeNumber: nil ] messageIncludes: 'Номер тому'.
    self assertError: [ volume volumeNumber: 1.5 ] messageIncludes: 'Номер тому'
]

{ #category : 'tests - validation' }
VolumeTest >> testVolumeNumberSetterRejectsZero [
    "volumeNumber: відхиляє нуль; повідомлення згадує номер тому"
    self assertError: [ volume volumeNumber: 0 ] messageIncludes: 'Номер тому'
]

{ #category : 'tests - comparing' }
VolumeTest >> testVolumesWithDifferentDataAreNotEqual [
    "Відмінність у будь-якому з трьох полів робить томи нерівними"
    self deny: volume = (Volume number: 3 pages: 300 title: 'Друга частина').
    self deny: volume = (Volume number: 2 pages: 301 title: 'Друга частина').
    self deny: volume = (Volume number: 2 pages: 300 title: 'Інша назва')
]
