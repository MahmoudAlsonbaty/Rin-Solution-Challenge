//Login

class UserNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

//Register
class EmailInUseAuthException implements Exception {}

class InvalidEmailOrPasswordException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class CouldNotRegisterUserException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//Generic
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
