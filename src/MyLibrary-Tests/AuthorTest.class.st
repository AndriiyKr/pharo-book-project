Class {
	#name : 'AuthorTest',
	#superclass : 'TestCase',
	#category : 'MyLibrary-Tests',
	#package : 'MyLibrary-Tests'
}

{ #category : 'tests' }
AuthorTest >> testAuthorFromDictionary [
    | dict author emptyDict emptyAuthor validDate |
    validDate := Date year: 1871 month: 2 day: 25.

    dict := Dictionary new.
    dict at: 'firstName' put: 'Леся';
         at: 'lastName' put: 'Українка';
         at: 'birthDate' put: validDate;
         at: 'city' put: 'Звягель'.
         
    author := Author authorFromDictionary: dict.
    self assert: author firstName equals: 'Леся'.
    self assert: author lastName equals: 'Українка'.
    self assert: author birthDate equals: validDate.
    self assert: author city equals: 'Звягель'.

    emptyDict := Dictionary new.
    emptyAuthor := Author authorFromDictionary: emptyDict.
    
    self assert: emptyAuthor firstName equals: Author defaultFirstName.
    self assert: emptyAuthor lastName equals: Author defaultLastName.
    self assert: emptyAuthor birthDate equals: Author defaultBirthDate.
    self assert: emptyAuthor city equals: Author defaultCity.
]

{ #category : 'tests' }
AuthorTest >> testBirthDate [
    | author validDate |
    author := Author new.
    validDate := Date year: 1856 month: 8 day: 27.

    author birthDate: validDate.
    self assert: author birthDate equals: validDate.

    author birthDate: nil.
    self assert: author birthDate equals: Author defaultBirthDate.

    self should: [ author birthDate: '27-08-1856' ] raise: Error.
    self should: [ author birthDate: 1856 ] raise: Error.
]

{ #category : 'tests' }
AuthorTest >> testCity [
    | author |
    author := Author new.
    
    author city: 'Львів'.
    self assert: author city equals: 'Львів'.
    
    author city: nil.
    self assert: author city equals: Author defaultCity.
    
    author city: ''.
    self assert: author city equals: Author defaultCity.
]

{ #category : 'tests' }
AuthorTest >> testConstructor [
    | author validDate |
    validDate := Date year: 1814 month: 3 day: 9.

    author := Author 
        firstName: 'Тарас' 
        lastName: 'Шевченко' 
        birthDate: validDate 
        city: 'Моринці'.
        
    self assert: author firstName equals: 'Тарас'.
    self assert: author lastName equals: 'Шевченко'.
    self assert: author birthDate equals: validDate.
    self assert: author city equals: 'Моринці'.

    author := Author firstName: nil lastName: nil birthDate: nil city: nil.
    self assert: author firstName equals: Author defaultFirstName.
]

{ #category : 'tests' }
AuthorTest >> testDefaultAuthor [
    | author |
    author := Author defaultAuthor.
    
    self assert: author firstName equals: Author defaultFirstName.
    self assert: author lastName equals: Author defaultLastName.
    self assert: author birthDate equals: Author defaultBirthDate.
    self assert: author city equals: Author defaultCity.
]

{ #category : 'tests' }
AuthorTest >> testFirstName [
    | author |
    author := Author new.
    author firstName: 'Іван'.
    self assert: author firstName equals: 'Іван'.
    author firstName: nil.
    self assert: author firstName equals: Author defaultFirstName.
    author firstName: ''.
    self assert: author firstName equals: Author defaultFirstName.
]

{ #category : 'tests' }
AuthorTest >> testFullName [
    | author |
    author := Author new.
    
    author firstName: 'Іван'; lastName: 'Нечуй-Левицький'.
    self assert: author fullName equals: 'Іван Нечуй-Левицький'.
    
    author firstName: nil; lastName: nil.
    self assert: author fullName equals: (Author defaultFirstName, ' ', Author defaultLastName).
]

{ #category : 'tests' }
AuthorTest >> testLastName [
    | author |
    author := Author new.
    
    author lastName: 'Франко'.
    self assert: author lastName equals: 'Франко'.
    
    author lastName: nil.
    self assert: author lastName equals: Author defaultLastName.
    
    author lastName: ''.
    self assert: author lastName equals: Author defaultLastName.
]
