//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

var upload_queue = {};

// get the HTML element by its id.
function $id(id) {
	return document.getElementById(id);
}


// call initialization file
function load() {
	if (window.File && window.FileList && window.FileReader) {
		Init();
	}
	else {
		alert('Your browser does not support HTML5 File APIs, please use recent version of Chrome or Filefox.')
	}
}

// initialize
function Init() {
	var fileselect = $id("fileselect"),
		filedrag = $id("filedrag"),
		submitbutton = $id("submitbutton");
	// file select
	fileselect.addEventListener("change", AddFile, false);
	// is XHR2 available?
	var xhr = new XMLHttpRequest();
	if (xhr.upload) {
		// file drop
		filedrag.addEventListener("dragover", DragHoverFile, false);
		filedrag.addEventListener("dragleave", DragHoverFile, false);
		filedrag.addEventListener("drop", AddFile, false);
		filedrag.style.display = "block";
		// remove submit button
		submitbutton.style.display = "none";
	}
	
	// upload all the files.....
	$("#upload_all").on('click', function (e) {
		var msg = "";
		var numRows = $id("queue").rows.length;
		for (var i = 0, row; row = $id("queue").rows[i]; i++) {
			// retrieve the file object;
			var file = jQuery.data(row, "filename");
			//var file = upload_queue[filename];
			//var file = $('#'+row.id).data("filename");
			var progress_bar = row.cells[4].firstChild.firstChild;
			UploadFile(file, progress_bar);
		}
	})
}

// file drag hover
function DragHoverFile(e) {
	e.stopPropagation();
	e.preventDefault();
	e.target.className = (e.type == "dragover" ? "hover" : "");
}

// Add files to the uploading queue
function AddFile(e) {
	// cancel event and hover styling
	DragHoverFile(e);
	// fetch FileList object
	var files = e.target.files || e.dataTransfer.files;
	// process all File objects
	for (var i = 0, f; f = files[i]; i++) {
		InspectFile(f);
//		UploadFile(f);
	}
}

// inspect the selected file
function InspectFile(file) {
	var id = "tr_" + file.name;
	var error = "";

	// check the file size, display a message if it's over the max_file_size
	if (file.size > $id("MAX_FILE_SIZE").value) {
		error = "Exceed maximum file size:" + $id("MAX_FILE_SIZE").value;
	}
	// check file type, display a message if it's not tarred or zipped.
	if (file.type.indexOf("zip") == -1 && file.type.indexOf("tar") == -1) {
		error = "Invalid file type, only tarred or zipped files are allowed";
	}
	
	// add a new row to the queue table
	var rowCount = $id("queue").rows.length;
    var row = $id("queue").insertRow(rowCount);
    row.id = id;

    var cell1 = row.insertCell(0);
	cell1.innerHTML = file.name;
	
	var cell2 = row.insertCell(1);
	if (error.length > 0) {
		cell2.innerHTML = "<div class=\"alert alert-error\">" + error + "</div>";
	} else {
		cell2.innerHTML = "";
	}
		
	var cell3 = row.insertCell(2);
	cell3.innerHTML = file.type;
	
	var cell4 = row.insertCell(3);
	cell4.innerHTML = file.size;
	
	var cell5 = row.insertCell(4);
	// create progress bar for the file
	// var progress = document.createElement("div");
	// progress.class = "progress progress-striped";
	// var bar = document.createElement("div");
	// bar.class = "bar";
	// bar.style = "width: 0%";
	// progress.appendChild(bar);
	var progress_bar = "<div class=\"progress progress-striped\"><div class=\"bar\" style=\"width: 0%;\"></div></div>";
	cell5.innerHTML = progress_bar;
	cell5.style.width = "20%"
	
	var cell6 = row.insertCell(5);
	// create cancel button
	var btn = "<button class=\"btn btn-warning\"type=\"button\">Cancel</button>";
	cell6.innerHTML = btn;
	
	$(".btn-warning").on('click', function (e) {
	    alert('cancel' + this.id);
	    // remove the current row from the queue table
        $(this).closest('tr').remove();
    })
	
	// attach the file object to the DOM element of the row.
	jQuery.data(row, "filename", file);
	//$('#'+id).data('file', file);
	
	// add File object to upload queue with the row number
	upload_queue[file.name] = file;

	// display an image
	// if (file.type.indexOf("image") == 0) {
	// 	var reader = new FileReader();
	// 	reader.onload = function(e) {
	// 		Output(
	// 			"<p><strong>" + file.name + ":</strong><br />" +
	// 			'<img src="' + e.target.result + '" /></p>'
	// 		);
	// 	}
	// 	reader.readAsDataURL(file);
	// }
}

// asynchronously upload a file
function UploadFile(file, progress) {
	var xhr = new XMLHttpRequest();
	if (xhr.upload && file.size <= $id("MAX_FILE_SIZE").value) {
		// add an event listener to the progress bar
		xhr.upload.addEventListener("progress", function(evt) {
			var percent = parseInt((evt.loaded/evt.total*100));
			// puts "percent = #{percent}";
			progress.style.width ='#{percent}%';
		}, false);
		// whether file uploading were received or failed
		xhr.onreadystatechange = function(evt) {
			if (xhr.readyState == 4) {
				progress.style.width ='100%';
			//	progress.className = (xhr.status == 200 ? "success" : "failure");
			}
		};
	    // start uploading
		xhr.open("POST", $id("upload").action, true);
		xhr.setRequestHeader("X_FILENAME", file.name);
		xhr.setRequestHeader("Content-Type", file.type);

		xhr.send(file);
	}
}
