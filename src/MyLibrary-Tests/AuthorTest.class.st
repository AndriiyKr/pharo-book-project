Class {
	#name : 'AuthorTest',
	#superclass : 'TestCase',
	#instVars : [
		'author'
	],
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'running' }
AuthorTest >> setUp [
    super setUp.
    author := Author 
        firstName: 'Іван' 
        lastName: 'Франко' 
        birthDate: (Date year: 1856 month: 8 day: 27) 
        city: 'Нагуєвичі'.
]

{ #category : 'tests' }
AuthorTest >> testAccessing [
    self assert: author firstName equals: 'Іван'.
    self assert: author lastName equals: 'Франко'.
    self assert: author city equals: 'Нагуєвичі'.
    self assert: author birthDate year equals: 1856.
    self assert: author birthDate monthIndex equals: 8.
]

{ #category : 'tests' }
AuthorTest >> testBirthDateTypeValidation [
    | validDate |
    self should: [ author birthDate: 1856 ] raise: Error.
    self should: [ author birthDate: '1856-08-27' ] raise: Error.
    validDate := Date today.
    author birthDate: validDate.
    self assert: author birthDate equals: validDate.
]

{ #category : 'tests' }
AuthorTest >> testConstructor [
    | newAuthor testDate |
    testDate := Date year: 1930 month: 3 day: 19.
    newAuthor := Author 
        firstName: 'Ліна' 
        lastName: 'Костенко' 
        birthDate: testDate 
        city: 'Ржищів'.

    self assert: newAuthor firstName equals: 'Ліна'.
    self assert: newAuthor lastName equals: 'Костенко'.
    self assert: newAuthor birthDate equals: testDate.
    self assert: newAuthor city equals: 'Ржищів'.
]

{ #category : 'tests' }
AuthorTest >> testDefaultAuthor [
    | defAuthor |
    defAuthor := Author defaultAuthor.
    
    self assert: defAuthor firstName equals: Author defaultFirstName.
    self assert: defAuthor lastName equals: Author defaultLastName.
    self assert: defAuthor city equals: 'Невідоме місто'.
    self assert: defAuthor birthDate equals: Date today.
]

{ #category : 'tests' }
AuthorTest >> testFullName [
    self assert: author fullName equals: 'Іван Франко'.
]

{ #category : 'tests' }
AuthorTest >> testFullNameWithMissingData [
    | emptyAuthor partialAuthor |

    emptyAuthor := Author new.
    self assert: emptyAuthor fullName equals: 'Невідомий Автор'.

    partialAuthor := Author new firstName: 'Леся'; yourself.
    self assert: partialAuthor fullName equals: 'Леся Автор'.

    partialAuthor := Author new lastName: 'Українка'; yourself.
    self assert: partialAuthor fullName equals: 'Невідомий Українка'.
]

{ #category : 'tests' }
AuthorTest >> testPrintOn [
    | stream resultString |
    stream := WriteStream on: String new.
    author printOn: stream.
    resultString := stream contents.
    self assert: (resultString includesSubstring: 'Іван Франко').
    self assert: (resultString includesSubstring: '(').
    self assert: (resultString includesSubstring: ')').
]

{ #category : 'tests' }
AuthorTest >> testSetters [
    | blankAuthor testDate |
    testDate := Date year: 1864 month: 9 day: 17.
    blankAuthor := Author new.

    blankAuthor firstName: 'Михайло'.
    blankAuthor lastName: 'Коцюбинський'.
    blankAuthor birthDate: testDate.
    blankAuthor city: 'Вінниця'.

    self assert: blankAuthor firstName equals: 'Михайло'.
    self assert: blankAuthor lastName equals: 'Коцюбинський'.
    self assert: blankAuthor birthDate equals: testDate.
    self assert: blankAuthor city equals: 'Вінниця'.
]
