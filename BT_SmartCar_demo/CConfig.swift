import Foundation


let JOG_LEFT = 1;
let JOG_RIGHT = 2;
let GESTURE_LEFT = 3;
let GESTURE_RIGHT = 4;
let GESTURE_UP = 5;
let GESTURE_DOWN = 6;
let BTN_BACK_TOUCH = 7;
let BTN_BACK_PUSH = 8;
let BTN_HOME_TOUCH = 9;
let BTN_HOME_PUSH = 10;
let BTN_NAVI_TOUCH = 11;
let BTN_NAVI_PUSH = 12;
let CONTROL_EMPTY = 13;


// CMD -------------------------------------------------------------------------
// RESPONSE
let RESPONSE_JOG_CMD:[UInt8] = [0x44]
let RESPONSE_CERT_NUM_CMD:[UInt8] = [0x61]
// REQUEST CMD
let CONNECT_CMD:[UInt8] = [0x11]
let DISCONNECT_CMD:[UInt8] = [0x12]
let REQUEST_PANIC_CMD:[UInt8] = [0x21]
let REQUEST_DOOR_OPEN_CMD:[UInt8] = [0x22]
let REQUEST_DOOR_CLOSE_CMD:[UInt8] = [0x23]
let REQUEST_MASTER_INIT_CMD:[UInt8] = [0x24]
// -------------------------------------------------------------------------------------------------


// MSG -----------------------------------------------------------------------------------------------
// Control REQUEST
let REQUEST_DOOR_OPEN:[UInt8] = [0x05, 0x44, 0x4F, 0x50, 0x45, 0x4E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
let REQUEST_DOOR_CLOSE:[UInt8] = [0x05, 0x44, 0x43, 0x4C, 0x4F, 0x53, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
let REQUEST_PANIC:[UInt8] = [0x05, 0x50, 0x41, 0x4E, 0x49, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
let REQUEST_MASTER_INIT:[UInt8] = [0x03, 0x01, 0x01, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

// JOG RESULT
let SUCCESS:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
let FAIL:[UInt8] = [0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

// --------------------------------------------------------
let login = "in"
let  logout = "out"
var  Email_id = ""
var  Email_addr = ""
var  phoneNumber = ""
var  phoneMacAddr = ""
let  master_email = "rndtest@norma.co.kr"
let  master_pwd = "normarnd123"
let  email_title = "[BT SMART CAR] E-MAIL VERIFICATION"
var response: [UInt8] = [0]



