			<div class="links_a">
                                <div class="fa fa-caret-up"></div>
                                <a class="no_hover" href="#popup" title="{$screenshot}">
                                        <img class="resborder resborder_{$result}" 
					height="45" 
					width="60" 
					src="testresults/{$screenshot}" 
					data-color="{$area_color}" 
					data-xpos="{$area_xpos}" 
					data-ypos="{$area_ypos}" 
					data-xsize="{$area_xsize}" 
					data-ysize="{$area_ysize}" 
					data-title="{$screenshot} (Similarity: {$img_similarity})"
					data-needle="Matching needle: {$needle}" 
					data-string="testresults/{$screenshot}" 
					onclick="window.click(this);">
				</a>
			</div>
