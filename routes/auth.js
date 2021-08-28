// ROUTES TO DO AUTHENTICATION

const express = require('express');
const passport = require('passport');

const { register, login, logout, getMe, forgotPassword, resetPassword, updateDetails, updatePassword, updatePhoto, passportAuthController } = require('../controllers/auth');

const { protect } = require('../middlewares/auth');

const  router  = express.Router();

router.get('/google', passport.authenticate('google', { 
    scope: ['email', 'profile']
}));

router.get('/google/callback', passport.authenticate('google', {
    failureRedirect: '/'
}), passportAuthController);

router
.post('/register', register);

router
.post('/login', login);

router
.get('/me', protect ,getMe);

router
.post('/forgotpassword', forgotPassword);

router
.put('/resetpassword/:resettoken', resetPassword);

router
.put('/updatedetails', protect, updateDetails);

router
.put('/updatepassword', protect, updatePassword);

router.get('/logout', protect, logout);

router
.put('/updatephoto', protect, updatePhoto);

module.exports = router;