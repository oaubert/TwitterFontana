coffee = require 'coffee-script'
fs = require 'fs'

module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')

        # watch
        watch:
            jade:
                files: ['frontend/src/**/*.jade']
                tasks: ['jade']
                options:
                    interrupt: true
            scss:
                files: ['frontend/src/css/**/*.scss']
                tasks: ['compass']
                options:
                    interrupt: true
            js:
                files: ['frontend/src/js/**/*.js', 'frontend/src/js/**/*.coffee']
                tasks: ['concat' ]
                options:
                    interrupt: true
            img:
                files: ['frontend/src/img/*.{png,jpg,jpeg,gif}'],
                tasks: ['imagemin']
                options:
                    interrupt: true

        # jade
        jade:
            options:
                preserveComments: false
            main:
                files:
                    'frontend/httpdocs/index.html': [
                        'frontend/src/index.jade'
                    ],
                    'frontend/httpdocs/fountain.html': [
                        'frontend/src/fountain.jade'
                    ],
                    'frontend/httpdocs/pop/twitter_success.html': [
                        'frontend/src/pop/twitter_success.jade'
                    ],
                    'frontend/httpdocs/pop/settings.html': [
                        'frontend/src/pop/settings.jade'
                    ]

        # concat
        concat:
            options: # parse coffee files when needed
                process: (src, filepath)->
                    if filepath.match(/\.coffee$/)
                        src = coffee.compile(src)
                    return src
            main:
                files:
                    'frontend/httpdocs/js/twitterfontana.js': [
                        'frontend/src/js/*.coffee'
                    ]
                    'frontend/httpdocs/js/lib.js': [
                        'frontend/src/js/lib/*.js'
                    ]
                    'frontend/httpdocs/js/demo.js': [
                        'frontend/src/js/demo/*.coffee'
                    ]

        # uglify
        uglify:
            options:
                preserveComments: false
            main:
                files:
                    'frontend/httpdocs/js/lib.min.js': 'frontend/httpdocs/js/lib.js'
                    'frontend/httpdocs/js/twitterfontana.min.js': 'frontend/httpdocs/js/twitterfontana.js'
                    'frontend/httpdocs/js/demo.min.js': 'frontend/httpdocs/js/demo.js'

        # compile sass to css
        compass:
            main:
                options:
                    sassDir: 'frontend/src/css'
                    cssDir: 'frontend/httpdocs/css'
                    relativeAssets: false
                    noLineComments: true
                    force: true
                    outputStyle: 'compressed'
                    require: ['animate']

        # optimize images
        imagemin:
            main:
                files: [
                    expand: true,
                    cwd: 'frontend/src/img/',
                    src: ['*.{png,jpg,jpeg,gif}'],
                    dest: 'frontend/httpdocs/img/'
                ]

    # Default: run all tasks, then start watch
    grunt.registerTask('default', ['jade', 'compass', 'concat',
                                   'uglify', 'imagemin', 'watch'])

    # include
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-compass'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-imagemin'
