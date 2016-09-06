// Include the Twilio Cloud Module and initialize it
var twilio = require("twilio");
twilio.initialize("<App ID>", "<App Key>");

/******************SMS Validation Code****************************/

/*Request SMS Validation Code*/
Parse.Cloud.define("sendCode", function(request, response) {

  var area = request.params.number.substring(0, 3);

  /*If Number is outside Toronto, return error*/
  if(area != 647 && area != 416 && area != 437){
    response.error("验证码获取失败");
  }

  /*Prepare the code*/
  var min = 1000;
  var max = 9999;
  var num = Math.floor(Math.random() * (max - min + 1)) + min;

  var User = Parse.Object.extend("_User");
  var user = new User();
  var queryUser = new Parse.Query(user);

  /*Check whether the user is existed*/
  queryUser.equalTo("username", request.params.number);
  queryUser.find({
    success: function(results) {
      /*If find any record, return false*/
      if (results.length > 0) {
        response.error("用户名已存在");
      } else {
        /*Check validation table*/
        var Validation = Parse.Object.extend("phone_validating_table");
        var Validation = new Validation();

        /*Check whether the record is existed*/
        var queryValidation = new Parse.Query(Validation);
        queryValidation.equalTo("phone", request.params.number);
        queryValidation.find({
          success: function(results) {
            if (results.length > 0) {
              var obj = results[0];
              /*If user had requested the SMS more than 5 times, block the user*/
              if (obj.get('count') >= 5) {
                obj.set("isBlocked", true);
                response.error("号码已被屏蔽");
              } else {
                /*Update the record and send the SMS*/
                var count = obj.get('count');
                obj.set("validation_code", num);
                obj.set("count", count + 1);
                obj.save();
                sendSMS(request.params.number, num);
                response.success("短信已发送");
              }
            } else {
              /*Create a new record*/
              Validation.set("phone", request.params.number);
              Validation.set("validation_code", num);
              Validation.set("isValid", false);
              Validation.set("count", 1);
              Validation.set("isBlocked", false);
              Validation.save(null, {
                success: function(Validation) {
                  /*Send SMS*/
                  sendSMS(request.params.number, num);
                  response.success("短信已发送");
                },
                error: function(Validation, error) {
                  /*Unable to create new record*/
                  response.error("获取验证码失败");
                }
              });
            }
          },
          error: function(error) {
            /*Unable to finish the query*/
            response.error("获取验证码失败");
          }
        });//find record
      }
    },
    error: function(error) {
      response.error("获取验证码失败");
    }
  }); //find user
});

/*Send the SMS*/
function sendSMS(phoneNum, num) {
  twilio.sendSMS({
    From: "+12898035283",
    To: "+1" + phoneNum,
    Body: "欢迎使用《友帮》，您的验证码为" + num
  }, {
    success: function(httpResponse) {
      console.log("SMS sent!");
    },
    error: function(httpResponse) {
      console.log("Uh oh, something went wrong");
    }
  });
}

/*Validate the code*/
Parse.Cloud.define("codeValidation", function(request, response) {
  var Validation = Parse.Object.extend("phone_validating_table");
  var query = new Parse.Query(Validation);

  /*Fecth the validation table*/
  query.equalTo("phone", request.params.number);
  query.find({
    success: function(results) {
      if (results.length > 0) {
        var obj = results[0];
        /*If the validation code is correct*/
        if (obj.get("validation_code") == request.params.code) {
          obj.set("isValid", true);
          obj.save();
          response.success(true);
        } else {
          obj.set("isValid", false);
          obj.save();
          response.success(false);
        }
      } else {
        /*Didn't find the number, should never reach here*/
        response.success(false);
      }
    },
    error: function(error) {
      /*Fetching failed*/
      response.error("验证失败，请稍后重试");
    }
  });
});

/*When user finish signup, delete the validation record*/
Parse.Cloud.define("deleteValidationRecord", function(request, response) {

  var Validation = Parse.Object.extend("phone_validating_table");
  var query = new Parse.Query(Validation);

  /*Fecth the validation table*/
  query.equalTo("phone", request.params.number);
  query.find({
    success: function(results) {

      if (results.length > 0) {
        var object = results[0];
        object.destroy({
          success: function(myObject) {
            /*Successfully delete the object, return true*/
            response.success(true);
          },
          error: function(myObject, error) {
            /*Delete failed*/
            response.error("操作失败，请稍后重试");
          }
        });
      } else {
        /*Didn't find the number, should never reach here*/
        response.success(false);
      }
    },
    error: function(error) {
      /*Fetching failed*/
      response.error("操作失败，请稍后重试");
    }
  });
});

/*********************Email Validation**********************************/

/*Check whether user has verfy the email*/
Parse.Cloud.define("checkEmailValidation", function(request, response) {
  var User = Parse.Object.extend("_User");
  // Create a new instance of that class.
  var user = new User();
  var query = new Parse.Query(user);

  query.equalTo("username", request.params.username);
  query.find({
    success: function(results) {
      // Do something with the returned Parse.Object values
      if (results.length > 0) {
        /*Pick the first one*/
        var obj = results[0];
        if (obj.get('email') == undefined) {
          response.error("用户未绑定邮箱，无法找回密码");
        } else if (obj.get('email') == request.params.email && obj.get('emailVerified') == true) {
          //validated
          response.success(true);
        } else {
          response.success(false);
        }
      } else {
        response.error("用户名不存在");
      }
    },
    error: function(error) {
      response.error("验证错误，请稍后重试");
    }
  }); //find
});


/************************Activation Code************************************/

/*Request Activation Code in App*/
Parse.Cloud.define("RequestActiviationCode", function(request, response) {

  var Validation = Parse.Object.extend("activation_code");
  var query = new Parse.Query(Validation);

  /*Fecth the validation table*/
  query.equalTo("hostphone", request.params.number);
  query.find({
    success: function(results) {

      /*If the user has already request a activation code, return it*/
      if (results.length > 0) {
        var object = results[0];
        response.success(object.get('activation_code'));
      } else {
        /*If this is the first time request, create a new record*/
        var code = GetCode();
        var ActivationCode = Parse.Object.extend("activation_code");
        var ActivationCode = new ActivationCode();

        ActivationCode.set("hostphone", request.params.number);
        ActivationCode.set("activation_code", code);
        ActivationCode.set("from_wechat", false);
        ActivationCode.save(null, {
          success: function(Validation) {
            /*Send back the code*/
            response.success(code);
          },
          error: function(Validation, error) {
            /*Unable to create new record*/
            response.error("获取激活码失败，请稍后重试");
          }
        });//save failed
      }
    },
    error: function(error) {
      /*Fetching failed*/
      response.error("操作失败，请稍后重试");
    }
  });
});

/*Generate the activation code*/
function GetCode() {
  return Math.random().toString(36).substr(2,8);
}

/*Validate the activation code*/
Parse.Cloud.define("ActivationCodeValidation", function(request, response) {
  var Activation = Parse.Object.extend("activation_code");
  var query = new Parse.Query(Activation);

  /*Fecth the validation table*/
  query.equalTo("activation_code", request.params.activationcode);
  query.find({
    success: function(results) {
      if (results.length > 0) {
        /*Validate success*/
        response.success(true);
      } else {
        response.success(false);
      }
    },
    error: function(error) {
      /*Fetching failed*/
      response.error("验证失败，请稍后重试");
    }
  });
});

/*Add one record in Promotion Table for activation code host*/
Parse.Cloud.define("deleteActivationCodeRecord", function(request, response) {

  var Activation = Parse.Object.extend("activation_code");
  var query = new Parse.Query(Activation);

  /*Fecth the validation table*/
  query.equalTo("activation_code", request.params.activationcode);
  query.find({
    success: function(results) {
      if (results.length > 0) {

        /*Check the hostphone number*/
        var object = results[0];
        var host = object.get("hostphone");

        /*Check promtion table*/
        var Promotion = Parse.Object.extend("promotion_table");
        var Promotion = new Promotion();

        /*Check whether the record is existed*/
        var queryPromotion = new Parse.Query(Promotion);
        queryPromotion.equalTo("phone", host);
        queryPromotion.find({
          success: function(result) {
            if (result.length > 0) {
              /*If the record is existed, add one count*/
              var obj = result[0];
              var count = obj.get('count');
              obj.set("count", count + 1);
              obj.save();
              response.success("0001:删除成功");
            } else {
              /*if not, Create a new record*/
              Promotion.set("phone", host);
              Promotion.set("count", 1);
              Promotion.save(null, {
                success: function(Validation) {
                  response.success("0002:删除成功");
                },
                error: function(Validation, error) {
                  /*Unable to create new record*/
                  response.error("更新错误");
                }
              });
            }
          },
          error: function(error) {
            /*Unable to finish the query*/
            response.error("查找错误");
          }
        });
      } else {
        /*Didn't find the number, should never reach here*/
        response.error("出现未知错误");
      }
    },
    error: function(error) {
      /*Fetching failed*/
      response.error("操作失败，请稍后重试");
    }
  });
});

/************************View Count*************************************/

/*Add one view count when the detail page was been viewed*/
Parse.Cloud.define("AddCount_Home", function(request, response) {
  var className = request.params.tablename
  var Home = Parse.Object.extend(className);
  var query = new Parse.Query(Home);

  /*Fecth the home table*/
  query.equalTo("objectId", request.params.objectid);
  query.find({
    success: function(results) {
      if (results.length > 0) {
        var obj = results[0];
        if(obj.get('view_count') == undefined){
            obj.set("view_count",1);
            obj.save();
        }else{
            var count = obj.get('view_count');
            obj.set("view_count",count + 1);
            obj.save();
        }
        response.success("成功");
      } else {
        response.error("出现未知错误");
      }
    },
    error: function(error) {
      /*Fetching failed*/
      response.error("出现未知错误");
    }
  });
});


// Parse.Cloud.define("Gnerate_Info", function(request, response) {
//
//
//     var Person = Parse.Object.extend("personal_info_table");
//     var query = new Parse.Query(Person);
//
//     query.equalTo("TargetId", request.params.target);
//     query.find({
//
//       success: function(results) {
//
//         var dict = []; // create an empty array
//         dict["User"] = request.params.from;
//         dict["Content"] = request.params.content;
//         dict["Page"] = request.params.link;
//         dict["Read"] = false;
//
//         if (results.length > 0) {
//           var obj = results[0];
//           if(obj.get('personal_info') == undefined){
//             var PersonalInfo = [];
//             PersonalInfo[0] = dict;
//             obj.set("personal_info", PersonalInfo);
//             obj.save();
//             response.success("成功1");
//           }else{
//             var PersonalInfo = obj.get('personal_info');
//             PersonalInfo.unshift(dict);
//             obj.set("personal_info", PersonalInfo);
//             obj.save();
//             response.success("成功2");
//           }
//         } else {
//
//           var dict = []; // create an empty array
//           dict["User"] = request.params.from;
//           dict["Content"] = request.params.content;
//           dict["Page"] = request.params.link;
//           dict["Read"] = false;
//
//           var PersonalInfo = [];
//           PersonalInfo[0] = dict;
//           var NewPerson = Parse.Object.extend("personal_info_table");
//           var PersonInfo = new NewPerson();
//           PersonInfo.set("personal_info", PersonalInfo);
//           PersonInfo.save(null, {
//             success: function(PersonInfo) {
//               response.success("生成成功");
//               // Execute any logic that should take place after the object is saved.
//               //alert('New object created with objectId: ' + gameScore.id);
//             },
//             error: function(PersonInfo, error) {
//                 response.error("生成失败");
//               // Execute any logic that should take place if the save fails.
//               // error is a Parse.Error with an error code and message.
//               //alert('Failed to create new object, with error code: ' + error.message);
//             }
//           });
//         //  response.error("未找到User");
//         }
//       },
//       error: function(error) {
//         /*Fetching failed*/
//         response.error("查找失败");
//       }
//     });
//
// });



/***************************Wechat Activity**********************************/

/*Submit the phone number when user finish the task*/
Parse.Cloud.define("submit_Wechat", function(request, response) {

  if(phoneValidation(request.params.number) == false){
    response.success("由于您的号码不属于本次活动范围，无法完成提交，我们表示抱歉");
  }

  /*Check how many people had sbmitted the number already*/
  var WechatSubmitCount = Parse.Object.extend("wechat_submit_table");
  var queryWechatSubmitCount = new Parse.Query(WechatSubmitCount);
  queryWechatSubmitCount.count({
    success: function(count) {
      /*Enough People*/
      if(count >= 50){
        response.success("我们的奖品名额已经被抢光啦，如果您已成功提交，我们会尽快核实并在活动结束之后发放奖品。如果您未能完成任务，我们还是非常感谢您的参与。未来我们还有更多有趣的活动，敬请期待");
      }else{
        /*Check Wether User Has Completed the Task*/
        var Promotion = Parse.Object.extend("promotion_table");
        var query = new Parse.Query(Promotion);
        query.equalTo("phone", request.params.number);
        query.find({
          success: function(results) {
            if (results.length > 0) {
              var obj = results[0];
              if (obj.get("count") >= 6) {
                /*Check wether user has submitted already*/
                var WechatSubmit = Parse.Object.extend("wechat_submit_table");
                var WechatSubmit = new WechatSubmit();

                /*Check whether the record is existed*/
                var queryWechatSubmit = new Parse.Query(WechatSubmit);
                queryWechatSubmit.equalTo("phone", request.params.number);
                queryWechatSubmit.find({
                  success: function(results) {
                    if (results.length > 0) {
                      response.success("您已经提交过啦，请不要重复提交");
                    } else {
                      /*Create a new record*/
                      WechatSubmit.set("phone", request.params.number);
                      WechatSubmit.save(null, {
                        success: function(Validation) {
                          /*Send SMS*/
                          response.success("恭喜你提交成功，我们会尽快核实并在活动结束后发放奖品");
                        },
                        error: function(Validation, error) {
                          /*Unable to create new record*/
                            response.success("提交失败，请稍后重试");
                        }
                      });
                    }
                  },
                  error: function(error) {
                    /*Unable to finish the query*/
                    response.success("提交失败，请稍后重试");
                  }
                });
              } else {
                response.success("您还没有完成任务哦，要抓紧时间啦");
              }
            } else {
              /*Didn't find the number*/
              response.success("您还没有完成任务哦，要抓紧时间啦");
            }
          },
          error: function(error) {
            /*Fetching failed*/
            response.success("提交失败，请稍后重试");
          }
        });
      }
    },
    error: function(error) {
      response.success("提交失败，请稍后重试");
    }
  });
});

/*Validate whether the phone is Toronto's phone number*/
function phoneValidation(num){
  var areacode = num.slice(0,3);
  if(areacode == 647 || areacode == 416 || areacode == 437){
      return true;
  }
  return false;
}

/*Check Task Status*/
Parse.Cloud.define("check_status", function(request, response) {

  if(phoneValidation(request.params.number) == false){
    response.success("由于您的号码不属于本次活动范围，无法参与本次活动，我们表示抱歉");
  }

  /*Check how many people had sbmitted the number already*/
  var WechatSubmitCount = Parse.Object.extend("wechat_submit_table");
  var queryWechatSubmitCount = new Parse.Query(WechatSubmitCount);
  queryWechatSubmitCount.count({
    success: function(count) {
      /*Enough People*/
      if(count >= 50){
        response.success("我们的奖品名额已经被抢光啦，如果您已提交任务，我们会尽快核实并在活动结束之后发放奖品。如果您未能完成任务，我们还是非常感谢您的参与。未来我们还有更多有趣的活动，敬请期待");
      }else{
        /*Check Wether User Has Completed the Task*/
        var Promotion = Parse.Object.extend("promotion_table");
        var query = new Parse.Query(Promotion);
        query.equalTo("phone", request.params.number);
        query.find({
          success: function(results) {
            if (results.length > 0) {
              var obj = results[0];
              if (obj.get("count") >= 6) {
                response.success("您已经完成任务啦，如果你还没有提交任务，请回复‘提交 手机号码’完成提交");
              } else {
                response.success("您还没有完成任务哦，再邀请" + (6 - obj.get("count")) + "位您的好友注册‘友帮’App就可以领奖啦，要抓紧时间啦");
              }
            } else {
              /*Didn't find the number*/
              response.success("您还没有完成任务哦，再邀请6位您的好友注册‘友帮’App就可以领奖啦，要抓紧时间啦");
            }
          },
          error: function(error) {
            /*Fetching failed*/
            response.success("提交失败，请稍后重试");
          }
        });
      }
    },
    error: function(error) {
      response.success("提交失败，请稍后重试");
    }
  });
});
