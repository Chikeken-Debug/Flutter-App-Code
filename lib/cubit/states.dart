abstract class AppStates {}

class AppInitial extends AppStates {}

// Sign in states
class UserSignInLoading extends AppStates {}

class UserVerifyLoading extends AppStates {}

class UserSignInError extends AppStates {}

class UserSignInDone extends AppStates {}

class UserSignInVerifyError extends AppStates {}

class CheckUserStateLoading extends AppStates {}

class CheckUserStateDone extends AppStates {}

//// Sign Up states
class UserSignUpLoading extends AppStates {}

class UserSignUpError extends AppStates {}

class UserSignUpDone extends AppStates {}

//// Forget password states
class UserForgetPassLoading extends AppStates {}

class UserForgetPassError extends AppStates {}

class UserForgetPassDone extends AppStates {}

//// Forget password states
class GetDataLoading extends AppStates {}

class GetDataDone extends AppStates {}

class GetAllGraphDataLoading extends AppStates {}

class GetAllGraphDataDone extends AppStates {}

class KeepAliveChecked extends AppStates {}

class CsvPrepared extends AppStates {}

class CsvPrepare extends AppStates {}

//// Send Configuration Data
class SendConfigLoading extends AppStates {}

class SendConfigDone extends AppStates {}

class SendConfigError extends AppStates {}

// additional
class ChangePassShowState extends AppStates {}

class SendDataToFireState extends AppStates {}

class NetworkConnectionChangeState extends AppStates {}

class ChangeRememberBoxShowState extends AppStates {}

class AppChangeScreen extends AppStates {}

class MainDrawerValuesListState extends AppStates {}

class ChangeDeviceStatus extends AppStates {}

class AddFarmDeviseState extends AppStates {}

//// Send user to edit Data
class SendToEditLoading extends AppStates {}

class SendToEditDone extends AppStates {}

class SendToEditError extends AppStates {}

//// GetPersonData
class GetPersonLoading extends AppStates {}

class GetPersonDone extends AppStates {}

class GetPersonError extends AppStates {}

//// GetPersonData
class GetEmployeeNamesLoading extends AppStates {}

class GetEmployeeNamesError extends AppStates {}

class GetEmployeeNamesDone extends AppStates {}

//// GetPersonData
class DeleteEmployeeLoading extends AppStates {}

class DeleteEmployeeDone extends AppStates {}
