                        </tbody>
    </table>
    
</div>


<div role="tabpanel" class="tab-pane" id="downloads" style="display:none">
	<div class="h5">Result Files</div>
	<ul>
		<li>
			<a href="video.ogv">
				<i title="ogg/theora video of this testrun" class="fa fa-file-video-o"></i> Video
			</a>
		</li>
		<li>
			<a href="vars.json">
				vars.json
			</a>
		</li>
		<li>
			<a href="serial0">
				serial0.txt
			</a>
		</li>
		<li>
			<a href="testresults/autoinst-log.txt">
				autoinst-log.txt
			</a>
		</li>
	</ul>
</div>

</div>
</div>

<div id="popup">
	<div class="window">
		<a href="#" class="close-button" title="Close">X</a>
		<h1 id="img_title"></h1>
		<h2 id="img_subtitle"></h2>
		<img id="img_in_overlay"  src="" width=100% style="display: none" alt="Image not loaded" />
		<canvas id="myCanvas" width="1024" height="768" style="width:100%;">
			Your browser does not support the HTML5 canvas tag.
		</canvas>
		<br />
	</div>
</div>
	
<script type="text/javascript">
	// Click on screenshot
	function click(element) {
		// Get values
		var rect_color = element.getAttribute("data-color");
		var rect_xpos = element.getAttribute("data-xpos");
		var rect_ypos = element.getAttribute("data-ypos");
		var rect_xsize = element.getAttribute("data-xsize");
		var rect_ysize = element.getAttribute("data-ysize");
		var img_link = element.getAttribute("data-string");
		var img_title = element.getAttribute("data-title");
		var needle = element.getAttribute("data-needle");
		
		// Set image link
		var fieldNameElement = document.getElementById('img_in_overlay');
		fieldNameElement.src = img_link;
		
		// Set image Title
		fieldNameElement = document.getElementById('img_title');
		fieldNameElement.innerHTML = img_title;
		// Set image SubTitle (needle infos)
		fieldNameElement = document.getElementById('img_subtitle');
		fieldNameElement.innerHTML = needle;
		
		var canvas = document.getElementById("myCanvas");
		var ctx = canvas.getContext("2d");
		var img = document.getElementById("img_in_overlay");
		ctx.drawImage(img, 0, 0);
		if(img_title.endsWith("png")){
			// Draw image and area used for match
			ctx.beginPath();
			ctx.rect(rect_xpos, rect_ypos, rect_xsize, rect_ysize);
			ctx.lineWidth = 2;
			ctx.strokeStyle = rect_color;
		}
		ctx.stroke();
	}
	// Click on tab
	function tabclick(evt, name) {
		var i;
		// Show/hide tabs
		var x = document.getElementsByClassName("tab-pane");
		for (i = 0; i < x.length; i++) {
			x[i].style.display = "none";
		}
		document.getElementById(name).style.display = "block";
		
		// Change tab title style
		tablinks = document.getElementsByClassName("tablink");
		for (i = 0; i < x.length; i++) {
			tablinks[i].parentNode.className = tablinks[i].parentNode.className.replace("active", "");
		}
		evt.currentTarget.parentNode.className += "active";
	}
</script>



</body>
</html>
