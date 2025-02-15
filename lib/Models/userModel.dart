class UserModel{
  String? uid;
  String? fullName;
  String? email;
  String? mobile;
  String? profilepic;

  UserModel({this.uid,this.fullName,this.email,this.mobile,this.profilepic});

  UserModel.fromMap(Map<String,dynamic>map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    mobile = map["mobile"];
    profilepic = map["profilepic"];
  }

  Map<String,dynamic> toMap(){
    return {
      "uid" : uid,
      "fullName" : fullName,
      "email" : email,
      "mobile":mobile,
      "profilepic":profilepic,
    };
  }
}