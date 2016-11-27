//
//  StringPool.swift
//  icome
//
//  Created by Tuo Zhang on 2015-09-30.
//  Copyright © 2015 iCome. All rights reserved.
//

import Foundation


//Global Variables

/*Cate for current use*/
let CATEGORY_DATA = [
                    "学术辅导",
                    "运动健身",
                    "美妆丽人",
                    "私厨美食",
                    "生活服务"
]

var pickerData = [String]()

//Cell Identifier
let HOME_PAGE_CELL_IDENTIFIER          =                      "home_page_cell"
let PHOTO_CELL_IDENTIFIER              =                      "photo_cell"
let DETAIL_PAGE_CELL_IDENTIFIER        =                      "detail_image_cell"
let NEW_POST_IMAGE_CELL_IDENTIFIER     =                      "new_post_image"

//Segue IDs
let LOGIN_SEGUE                        =                      "login"

//Storyboard IDs
let SETTING_NAV                        =                      "setting_nav"
let HOME_NAV                           =                      "home_nav"
let REPORT_NAV                         =                      "report_nav"
let NEW_POST_NAV                       =                      "new_post"
let DETAIL_NAV                         =                      "detail_nav"
let LOGIN_NAV                          =                      "login"
let SIGN_UP_PROFILE                    =                      "sign_up_profile"
let GET_VALIDATION_PAGE                =                      "sign_up"
let PHONE_VALIDATION_PAGE              =                      "phone_validation"

//Error Alert Info
let ERROR_ALERT                        =                      "错误"
let ERROR_EMPTY_CONTENT                =                      "内容不能为空"
let ERROR_EMPTY_PRICE                  =                      "价格不能为空"
let ERROR_EMPTY_UNIT                   =                      "单位不能为空"
let ERROR_EMPTY_DESCRIPTION            =                      "描述不能为空"
let ERROR_PLEASE_SELECT_CATEGORY       =                      "请选择类别"
let ERROR_TOO_MANY_WORDS               =                      "字数过多"
let ERROR_GET_VALIDATION_CODE          =                      "获取验证码失败"
let ERROR_USER_ALREADY_EXIST           =                      "用户名已经存在"
let ERROR_LOGIN_ERROR                  =                      "登录失败，请稍后重试"
let ERROR_WRONG_TYPE_USERNAME          =                      "请输入正确的用户名"
let ERROR_WRONG_TYPE_PASSWORD          =                      "密码格式错误"
let ERROR_WRONG_TYPE_EMAIL             =                      "请输入正确的E－mail地址"
let ERROR_EMPTY_EMAIL                  =                      "E－mail地址不能为空"
let ERROR_EMPTY_PHONENUMBER            =                      "手机号码不能为空"
let ERROR_EMAIL_NOT_BIND               =                      "请先绑定邮箱"
let ERROR_WRONG_TYPE_CELL_PHONE        =                      "请输入正确的手机号"
let ERROR_WRONG_TYPE_VALIDATION_CODE   =                      "请输入正确格式的验证码"
let ERROR_SEND_MESSAGE_FAIL            =                      "发送失败"
let ERROR_POST_FAIL                    =                      "发布失败"
let ERROR_VALIDATION_FAIL              =                      "验证失败"
let ERROR_SIGNUP_FAIL                  =                      "注册失败"
let ERROR_IMAGE_CHANGE_FAIL            =                      "更改失败"
let ERROR_LOADING_IMAGE                =                      "载入图片失败"
let ERROR_FIND_PASSWORD_FAIL           =                      "找回密码失败"
let ERROR_INVALID_ACCOUNT              =                      "用户名或密码输入错误"
let ERROR_EMPTY_INPUT                  =                      "手机号码或密码不能为空"
let ERROR_PASSWORD_NOT_MATCH           =                      "两次密码输入不一致"
let ERROR_ALERT_ACTION                 =                      "知道了"
let RETRY                              =                      "重试"

//Alert
let ALERT                              =                      "提示"

//Successs
let ALERT_SUCCESS                      =                      "发送成功"
let ALERT_THANKS_FOR_SUGGESTION        =                      "感谢您的宝贵意见"
let ALERT_BACK_TO_SETTING              =                      "返回设置"
let ALERT_REPORT_RECEIVED              =                      "我们已经收到您的举报，将会尽快核实"
let ALERT_BACK_TO_MAIN                 =                      "返回首页"


//binding email
let ALERT_EMAIL_NOT_BIND_YET           =                      "您的账号暂未绑定邮箱，您可以在“我的设置”中进行绑定。为了方便您更改或找回密码，请尽快绑定邮箱。"
let ALERT_DO_EMAIL_VALIDATION_SOON     =                      "一封确认邮件已经发送到您的邮箱中，请您尽快查收并完成验证，如果没有收到邮件，请在“我的设置”中重新进行邮箱绑定。"
let ALERT_DO_PASSWORD_RESET_SOON       =                      "一封邮件已经发送到您的邮箱中，请您尽快查收并完成密码修改。"
let ALERT_ACTION                       =                      "知道了"
let ALERT_EMAIL_VALIDATION_SENT        =                      "一封确认邮件已经发送到您的邮箱中，请您尽快查收并完成验证。"

