module.exports = {
    // parser: '@typescript-eslint/parser', // Specifies the ESLint parser
    parserOptions: {
        ecmaVersion: 2020,
        sourceType: "commonjs",
        // Allows for the use of imports
        ecmaFeatures: {
            jsx: true, // Allows for the parsing of JSX
        },
    },

    settings: {
        react: {
            version: "detect", // Tells eslint-plugin-react to automatically detect the version of React to use
        },
    },

    extends: ["react-app", "react-app/jest", "plugin:react/recommended"],
    plugins: ["react", "react-hooks"],
    rules: {
        "react/react-in-jsx-scope": "off",
        "jsx-a11y/anchor-is-valid": "off",
        //'no-inner-declarations': 'off',
        // Place to specify ESLint rules. Can be used to overwrite rules specified from the extended configs
        // e.g. "@typescript-eslint/explicit-function-return-type": "off",
    },
};
