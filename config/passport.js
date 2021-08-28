const GoogleStrategy = require('passport-google-oauth20').Strategy;
const mongoose = require('mongoose');
const User = require('../models/Users');

module.exports = function (passport) {
    passport.use(new GoogleStrategy({
        clientID: process.env.GOOGLE_CLIENT_ID_WEBAPP,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: '/api/v1/auth/google/callback'
    },
        async (accessToken, refreshToken, profile, done) => {
            const identities = {
                provider: 'google',
                auth_id: profile.id
            };
            const newUser = {
                username: profile.displayName,
                email: profile.emails[0].value,
                photo: profile.photos[0].value,
                identities: [identities],
                password: identities.auth_id
            };

            try {
                var user = await User.findOne({ email: newUser.email });
                if (!user) {
                    user = await User.create(newUser);
                } else {
                    await User.findByIdAndUpdate(user._id, {
                        $addToSet: {
                            identities
                        }
                    }, {
                        new: true,
                        runValidators: true
                    });
                } 
                done(null, user);
            } catch (error) {
                console.error(error);
            }
        }
    ));

    passport.serializeUser((user, done) => done(null, user.id));

    passport.deserializeUser((id, done) => User.findById(id, (err, user) => done(err, user)));
}