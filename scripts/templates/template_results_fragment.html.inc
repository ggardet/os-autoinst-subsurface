		<div class="col-lg-2 text-nowrap">
			<a href="{$link_to_tests_details}" target="_blank"><span class="h5">{$date} (UTC)</span></a>
		</div>
		<div class="col-lg-7">
			<div class="progress build-dashboard" title="passed: {$nb_passed_tests}
softfailed: {$nb_softfail_tests}
failed: {$nb_fail_tests}
total: {$nb_tests}">
			<div class="progress-bar progress-bar-passed " style="width: {$pc_passed_tests}%;">{$nb_passed_tests} passed</div>
			<div class="progress-bar progress-bar-softfailed " style="width: {$pc_softfail_tests}%;">{$nb_softfail_tests} softfailed</div>
			<div class="progress-bar progress-bar-failed " style="width: {$pc_fail_tests}%;">{$nb_fail_tests} failed</div>
			<div class="progress-bar progress-bar-skipped " style="width: {$pc_skipped_tests}%;">{$nb_skipped_tests} skipped</div>

			</div>
		</div>
