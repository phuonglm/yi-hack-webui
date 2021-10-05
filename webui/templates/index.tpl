<html>

    <head>
        <title>{$doc_title}</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="scripts/node_modules/bootstrap/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="scripts/node_modules/font-awesome/css/font-awesome.min.css">
        <link rel="stylesheet" href="scripts/node_modules/bootstrap-datepicker/dist/css/bootstrap-datepicker3.min.css">
        <link rel="stylesheet" href="scripts/node_modules/bootstrap4-fs-modal/dist/css/bootstrap-fs-modal.min.css" >
        <link rel="stylesheet" href="scripts/node_modules/video.js/dist/video-js.css">

        <script type="text/javascript" src="scripts/node_modules/jquery/dist/jquery.min.js"></script>
        <script type="text/javascript" src="scripts/node_modules/bootstrap/dist/js/bootstrap.min.js"></script>
        <script type="text/javascript" src="scripts/node_modules/bootstrap-autohidingnavbar/dist/jquery.bootstrap-autohidingnavbar.min.js"></script>
        <script type="text/javascript" src="scripts/node_modules/jquery-touchswipe/jquery.touchSwipe.min.js"></script>

        <!--Load the AJAX API-->
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

        <script type="text/javascript" src="scripts/node_modules/moment/min/moment.min.js"></script>
        <script type="text/javascript" src="scripts/node_modules/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js"></script>

        <script type="text/javascript" src="scripts/node_modules/video.js/dist/video.js"></script>
        <script type="text/javascript" src="scripts/node_modules/videojs-playlist/dist/videojs-playlist.min.js"></script>

    </head>

    <body>
        <nav class="navbar navbar-light bg-light navbar-expand-md">
            <div class="container">
                <button type="button" class="navbar-toggler collapsed" data-toggle="collapse"
                data-target="#navbar" aria-expanded="false" aria-controls="navbar"> <span class="sr-only">Toggle navigation</span>
&#x2630;</button> <a class="navbar-brand"
                href="#" style="font-size: 2em;">Camera Visualizer</a>
                <div class="collapse navbar-collapse"
                id="navbar">
                    <ul class="nav navbar-nav ml-auto">
                        <li class="dropdown nav-item"> <a href="#" class="dropdown-toggle fa fa-video-camera fa-2x nav-link"
                            data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"> <span class="caret"></span></a>
                            <ul
                            class="dropdown-menu">{section name=id loop=$devices}
                                <li class="dropdown-item"><a href="#">{$devices[id]}</a>
                                </li>{/section}</ul>
                    </li>
                    <li class="dropdown nav-item"> <a href="#" id="date-dropdown" class="dropdown-toggle fa fa-calendar fa-2x nav-link"
                        data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"> {$time_range} <span class="caret"></span></a>
                        <ul
                        class="dropdown-menu dropdown-menu-right">
                            <li class="dropdown-item">
                                <div id="date-selector"></div>
                            </li>
                            </ul>
                    </li>
                    </ul>
                </div>
            </div>
        </nav>
        <div class="container">
            <div class="row">
                <div class="col-12"></div>
            </div>
            <div class="row">
                <div class="col-12" style="visibility: hidden;"> <a name="end" href="#end">end</a>
                </div>
            </div>
        </div>
        <!--Div that will hold the pie chart-->
        <div id="chart_div" style="padding: 0.7em"></div>
        {include file="player.tpl"}
        <script src="scripts/main.js"></script>
        <script type="text/javascript">
            window.time_offset = {$time_offset};
        </script>
  </body>
</html>
