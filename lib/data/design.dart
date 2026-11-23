enum Screen {
  splash('191:1183', 'Splash Screen'),
  onboardingOne('188:2311', 'Onboarding 01'),
  onboardingTwo('191:1242', 'Onboarding 02'),
  onboardingThree('251:1966', 'Onboarding 03'),
  login('58:2383', 'Log In - Empty'),
  loginActive('58:2405', 'Log In - Active'),
  signUp('58:2427', 'Sign Up - Empty'),
  signUpActive('58:2447', 'Sign Up - Active'),
  verifyEmail('58:2467', 'Verification code'),
  forgot('58:2481', 'Forgot password'),
  resetEmail('58:2492', 'Reset password - Email address'),
  resetPhone('58:2501', 'Reset password - Phone number'),
  verifyPhone('58:2510', 'Verification code 02'),
  newPassword('58:2524', 'New Password'),
  passwordChanged('58:2535', 'New Password - Success'),
  homeOne('197:1008', 'Home - Variant 01'),
  homeTwo('63:2233', 'Home - Variant 02'),
  homeThree('183:1002', 'Home - Variant 03'),
  foodOne('69:4210', 'Food Details - Variant 01'),
  foodTwo('286:1293', 'Food Details - Variant 02'),
  foodThree('131:1595', 'Food Details - Variant 03'),
  foodExpanded('286:1362', 'Food Details - Variant 03 Expand'),
  location('241:1126', 'Select Location'),
  locationTyping('241:1249', 'Select Location - Typing'),
  cart('241:1762', 'Cart'),
  payment('242:1115', 'Payment'),
  voucher('251:1745', 'Select Voucher'),
  selectPayment('251:821', 'Select Payment Method'),
  tracking('234:1201', 'Tracking'),
  favouriteList('303:1133', 'Favourite - Variant 02 / List'),
  favouriteGrid('303:1470', 'Favourite - Variant 02 / Grid'),
  promos('303:1850', 'Promos'),
  profile('301:3665', 'Profile'),
  notification('302:1346', 'Notification'),
  search('302:1788', 'Search'),
  searchEmpty('302:2012', 'Search No Result'),
  editProfile('310:1496', 'Edit Profile'),
  deliveryLocation('310:1667', 'Delivery Location'),
  paymentSettings('251:1076', 'Payment Setting'),
  cardOptions('251:1454', 'Payment Setting - Option'),
  addCard('251:1557', 'Payment Setting - Add Card');

  const Screen(this.node, this.title);
  final String node;
  final String title;

  String get slug => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '-${match[0]!.toLowerCase()}',
  );
}
