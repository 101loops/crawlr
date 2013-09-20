module.exports = (grunt) ->

  grunt.initConfig

    # ==== CLEAN

    # https://npmjs.org/package/grunt-clean
    clean:
      crawler: [
        "bin"
      ]


    # ==== COPY

    # https://npmjs.org/package/grunt-contrib-copy
    copy:
      crawler:
        files: [
          {
            cwd: "."
            src: ["package.json", "Procfile"]
            dest: "bin"
            expand: true
          }
        ]


    # ==== COFFEE

    # https://npmjs.org/package/grunt-contrib-coffee
    coffee:
      options:
        bare: true
        #sourceMap: true

      crawler:
        expand: true
        cwd: "."
        src: ["**/*.coffee"]
        dest: "bin"
        ext: ".js"


    # ==== SIMPLE-MOCHA

    # https://npmjs.org/package/grunt-simple-mocha
    simplemocha:
      options:
        globals: ["should"],
        timeout: 3000,
        ignoreLeaks: false,
        ui: "bdd",
        reporter: "tap"

      crawler:
        src: "bin/test/**/*.js"


    # ==== GIT-DEPLOY

    # https://npmjs.org/package/grunt-git-deploy
    git_deploy:
      options:
        branch: "master"

      crawler:
        options:
          url: "git@heroku.com:crawlr.git"
        src: "bin"


    # ==== EXPRESS

    # https://npmjs.org/package/grunt-express
    express:
      crawler:
        options:
          background: false
          script: "bin/app.js"


  # plugins
  # ================================================================================

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-watch"

  grunt.loadNpmTasks "grunt-express-server"
  grunt.loadNpmTasks "grunt-go"
  grunt.loadNpmTasks "grunt-simple-mocha"


  # tasks
  # ================================================================================

  # default / build
  grunt.registerTask("default", "Build the application", ->
    grunt.task.run("clean:crawler", "copy:crawler", "coffee:crawler")
  )
  grunt.registerTask "build", ["default"]

  # run
  grunt.registerTask("run", "Run the application", ->
    grunt.task.run("build", "express")
  )

  # test
  grunt.registerTask("test", "Test the application", ->
    grunt.task.run("build", "simplemocha:crawler")
  )

  # deploy
  grunt.registerTask("deploy", "Deploy the application", ->
    grunt.task.run("build", "git_deploy:crawler")
  )