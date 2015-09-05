/**
  * JavaScript functionality for DataStax Intern Showcase: Dev Tools & Drivers (Summer 2015)
  *
  * @author Kevin Gallardo
  * @author Jiangcheng Oliver Chu
  *
 **/

// import 'js/jquery-1.11.3.min.js';

var ds_showcase = {};

(function Slideshow(app) {
     /**
      * The main function for this JavaScript application.
      * @param args the command line args
      */
     app.main = function(args) {
         private_methods.allow_print_export_pdfs();

//         var interval = 2000;
//         app.processes.launch(
//             'jenkins.matrix-refresher',
//             interval,
//             launchers.JenkinsRefresher(interval)
//         );

         interval = 500;
         app.processes.launch(
             'aidan.mvc-framework',
             interval,
             launchers.AidanMVCFramework(interval)
         );
     }

     app.processes = {};
     (function ProcessManager(processes) {
       processes.launch = function(name, period, fxn) {
         var process = {
           name:   name,
           period: period,
           fxn:    fxn
         }
         var pid = window.setTimeout(fxn, 1);
         process_table[pid] = process;
       };

       processes.kill = function(pid) {
         window.clearTimeout(pid);
         delete process_table[pid];
       }

       var process_table = {};
     })(app.processes);

     /** All private methods follow. */
     var private_methods = {};

     private_methods.allow_print_export_pdfs = function() {
         var link = $( '<link>' ).attr({
             rel:  'stylesheet',
             type: 'text/css',
             href: 'css/print/' + (window.location.search.match( /print-pdf/gi ) ? 'pdf.css' : 'paper.css')
         });
         $( 'head' ).append(link);
     };

     /** All process launchers follow. */
     var launchers = {};

     launchers.JenkinsRefresher = function(interval) {
         console.log('JenkinsMatrixRefresher: requesting every ' + (interval / 1000.0) + ' seconds...');
         var analytics = $( '#jenkins-analytics' );
         var count_substrings = function(haystack, needle) {
            return (haystack.match(new RegExp(needle, 'g')) || []).length
         }
         var render_data = function(jenkins_data) {
             var width  = jenkins_data.grid[0];
             var height = jenkins_data.grid[1];
             var elems  = jenkins_data.grid[2];
             return '' + width + 'x' + height + ' matrix, ' +
                    + count_substrings(elems, 'w') + ' pending, ' + count_substrings(elems, 's') + ' done'
         }
         var page_index = Reveal.getIndices().h
         if (typeof (page_index) === 'number') {
             page = page_index + 1;
             if (5 <= page && page <= 9) {
                 $.ajax({
                     type:    'GET',
                     url:     'matrix.json',
                     success: function(data) { 
                         var rendered = render_data(data);
                         if (typeof (rendered) === 'string') {
                             analytics.html(rendered);
                         }
                     },
                     error: function() {
                         analytics.html('Jenkins: java.lang.NullPointerException');
                         console.log('Jenkins offline');
                     }
                 });
             } else {
                 analytics.html('');
                 console.log('not rendering Jenkins analytics b/c page is not between 5 and 9');
             }
         }
         window.setTimeout(launchers.JenkinsRefresher, interval, interval);
     };

     launchers.AidanMVCFramework = function(interval) {
         //Don't log this:
         //console.log('Aidan MVC Framework: updating page every ' + (interval / 1000.0) + ' seconds...');
         var page_index = Reveal.getIndices().h;
         var page;
         if (typeof (page_index) === 'number') {
             page = '' + (page_index + 1);
         } else {
             page = '?';
         }
         $( '#page-number' ).html(page);
         window.setTimeout(launchers.AidanMVCFramework, interval, interval);
     };
})(ds_showcase);

