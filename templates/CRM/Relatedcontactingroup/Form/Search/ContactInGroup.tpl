{*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.4                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2013                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*}
{* Default template custom searches. This template is used automatically if templateFile() function not defined in
   custom search .php file. If you want a different layout, clone and customize this file and point to new file using
   templateFile() function.*}
<div class="crm-block crm-form-block crm-contact-custom-search-form-block">
<div class="crm-accordion-wrapper crm-custom_search_form-accordion {if $rows}collapsed{/if}">
    <div class="crm-accordion-header crm-master-accordion-header">
      {ts}Edit Search Criteria{/ts}
    </div><!-- /.crm-accordion-header -->
    <div class="crm-accordion-body">
        <div class="crm-submit-buttons">{include file="CRM/common/formButtons.tpl" location="top"}</div>

        <div class="crm-accordion-wrapper crm-search_criteria_basic-accordion">
            <div class="crm-accordion-header active">{ts}Search contact{/ts}</div>
            <div class="crm-accordion-body">
                <table class="form-layout">
                    <tr>
                        <td>
                            <div id='groupselect'><label>{$form.group_id.label}</label>
                                {$form.group_id.html}
                                {literal}
                                    <script type="text/javascript">
                                        cj("select#group_id").crmasmSelect({
                                            respectParents: true
                                        });
                                    </script>
                                {/literal}
                            </div>
                        </td>
                        <td colspan="3">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <div>
                                <label>{$form.is_deceased.label}</label><br />
                                {$form.is_deceased.html}
                                <span class="crm-clear-link">(<a href="#" title="unselect" onclick="unselectRadio('is_deceased', 'Advanced'); return false;" >{ts}clear{/ts}</a>)</span>
                            </div>
                        </td>
                        <td colspan="3">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            {$form.privacy_toggle.html}
                        </td>
                        <td colspan="3">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            {$form.privacy_options.html}
                        </td>
                        <td colspan="3">&nbsp;
                            {literal}
                                <script type="text/javascript">
                                    cj("select#privacy_options").crmasmSelect();
                                </script>
                            {/literal}
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <div class="crm-accordion-wrapper crm-search_criteria_basic-accordion">
            <div class="crm-accordion-header active">{ts}Related contact{/ts}</div>
            <div class="crm-accordion-body">
                <table class="form-layout">
                    <tr>
                        <td>
                            {$form.including_excluding.html}
                        </td>
                        <td colspan="3">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <div><label>{$form.relationship_type_id.label}</label>
                                {$form.relationship_type_id.html}
                                {literal}
                                    <script type="text/javascript">
                                        cj("select#relationship_type_id").crmasmSelect({
                                            respectParents: true
                                        });
                                    </script>
                                {/literal}
                            </div>
                        </td>
                        <td colspan="3">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <div><label>{$form.related_group_id.label}</label>
                                {$form.related_group_id.html}
                                {literal}
                                    <script type="text/javascript">
                                        cj("select#related_group_id").crmasmSelect({
                                            respectParents: true
                                        });
                                    </script>
                                {/literal}
                            </div>
                        </td>
                        <td colspan="3">&nbsp;</td>
                    </tr>
                </table>
            </div>
        </div>


        <div class="crm-submit-buttons">{include file="CRM/common/formButtons.tpl" location="bottom"}</div>
    </div><!-- /.crm-accordion-body -->
</div><!-- /.crm-accordion-wrapper -->
</div><!-- /.crm-form-block -->

{if $rowsEmpty || $rows}
<div class="crm-content-block">
{if $rowsEmpty}
    {include file="CRM/Contact/Form/Search/Custom/EmptyResults.tpl"}
{/if}

{if $summary}
    {$summary.summary}: {$summary.total}
{/if}

{if $rows}
  <div class="crm-results-block">
    {* Search request has returned 1 or more matching rows. Display results and collapse the search criteria fieldset. *}
        {* This section handles form elements for action task select and submit *}
       <div class="crm-search-tasks">
        {include file="CRM/Contact/Form/Search/ResultTasks.tpl"}
    </div>
        {* This section displays the rows along and includes the paging controls *}
      <div class="crm-search-results">

        {include file="CRM/common/pager.tpl" location="top"}

        {* Include alpha pager if defined. *}
        {if $atoZ}
            {include file="CRM/common/pagerAToZ.tpl"}
        {/if}

        {strip}
        <table class="selector" summary="{ts}Search results listings.{/ts}">
            <thead class="sticky">
                <tr>
                <th scope="col" title="Select All Rows">{$form.toggleSelect.html}</th>
                {foreach from=$columnHeaders item=header}
                    <th scope="col">
                        {if $header.sort}
                            {assign var='key' value=$header.sort}
                            {$sort->_response.$key.link}
                        {else}
                            {$header.name}
                        {/if}
                    </th>
                {/foreach}
                <th>&nbsp;</th>
                </tr>
            </thead>

            {counter start=0 skip=1 print=false}
            {foreach from=$rows item=row}
                <tr id='rowid{$row.contact_id}' class="{cycle values="odd-row,even-row"}">
                    {assign var=cbName value=$row.checkbox}
                    <td>{$form.$cbName.html}</td>
                    {foreach from=$columnHeaders item=header}
                        {assign var=fName value=$header.sort}
                        {if $fName eq 'sort_name'}
                            <td><a href="{crmURL p='civicrm/contact/view' q="reset=1&cid=`$row.contact_id`"}">{$row.sort_name}</a></td>
                        {else}
                            <td>{$row.$fName}</td>
                        {/if}
                    {/foreach}
                    <td>{$row.action}</td>
                </tr>
            {/foreach}
        </table>
        {/strip}

        <script type="text/javascript">
        {* this function is called to change the color of selected row(s) *}
        var fname = "{$form.formName}";
        on_load_init_checkboxes(fname);
        </script>

        {include file="CRM/common/pager.tpl" location="bottom"}

        </p>
    {* END Actions/Results section *}
    </div>
    </div>
{/if}



</div>
{/if}
{literal}
<script type="text/javascript">
cj(function() {
   cj().crmAccordions();
});

function toggleContactSelection( name, qfKey, selection ){
  var Url  = "{/literal}{crmURL p='civicrm/ajax/markSelection' h=0}{literal}";

  if ( selection == 'multiple' ) {
    var rowArr = new Array( );
    {/literal}{foreach from=$rows item=row  key=keyVal}
      {literal}rowArr[{/literal}{$keyVal}{literal}] = '{/literal}{$row.checkbox}{literal}';
    {/literal}{/foreach}{literal}
    var elements = rowArr.join('-');

    if ( cj('#' + name).is(':checked') ){
      cj.post( Url, { name: elements , qfKey: qfKey , variableType: 'multiple' } );
    }
    else {
      cj.post( Url, { name: elements , qfKey: qfKey , variableType: 'multiple' , action: 'unselect' } );
    }
  }
  else if ( selection == 'single' ) {
    if ( cj('#' + name).is(':checked') ){
      cj.post( Url, { name: name , qfKey: qfKey } );
    }
    else {
      cj.post( Url, { name: name , qfKey: qfKey , state: 'unchecked' } );
    }
  }
  else if ( name == 'resetSel' && selection == 'reset' ) {
    cj.post( Url, {  qfKey: qfKey , variableType: 'multiple' , action: 'unselect' } );
    {/literal}
    {foreach from=$rows item=row}{literal}
      cj("#{/literal}{$row.checkbox}{literal}").removeAttr('checked');{/literal}
    {/foreach}
    {literal}
    cj("#toggleSelect").removeAttr('checked');
    var formName = "{/literal}{$form.formName}{literal}";
    on_load_init_checkboxes(formName);
  }
}
</script>

{/literal}
