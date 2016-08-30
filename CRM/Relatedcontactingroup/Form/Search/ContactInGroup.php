<?php

/**
 * A custom contact search
 */
class CRM_Relatedcontactingroup_Form_Search_ContactInGroup extends CRM_Contact_Form_Search_Custom_Base implements CRM_Contact_Form_Search_Interface {

  private $_group;

  function __construct(&$formValues) {
    parent::__construct($formValues);
    $this->_group = CRM_Core_PseudoConstant::nestedGroup();
  }

  /**
   * Method to get groups
   *
   * @return array
   * @access protected
   */
  protected function getGroups() {
    $groupHierarchy = CRM_Contact_BAO_Group::getGroupsHierarchy($this->_group, NULL, '&nbsp;&nbsp;', TRUE);
    return $groupHierarchy;
  }

  protected function getRelationshipTypes() {
    $relationship_types = civicrm_api3('RelationshipType', 'get', array('option.limit' => 9999999));
    $return = array();
    foreach($relationship_types['values'] as $rel_type) {
      $return[$rel_type['id']] = $rel_type['label_a_b'];
    }
    return $return;
  }

  /**
   * Prepare a set of search fields
   *
   * @param CRM_Core_Form $form modifiable
   * @return void
   */
  function buildForm(&$form) {
    CRM_Utils_System::setTitle(ts('Search (in/ex)cluding related contacts within a group'));

    $groups = $this->getGroups();
    $form->add('select', 'group_id', ts('Group'), $groups, true,
      array('id' => 'group_id', 'multiple' => 'multiple', 'title' => ts('- select -'))
    );

    $form->addYesNo('is_deceased', ts('Is deceased?'));

    // checkboxes for DO NOT phone, email, mail
    // we take labels from SelectValues
    $t = CRM_Core_SelectValues::privacy();
    $form->add('select',
      'privacy_options',
      ts('Privacy'),
      $t,
      FALSE,
      array(
        'id' => 'privacy_options',
        'multiple' => 'multiple',
        'title' => ts('- select -'),
      )
    );

    $options = array(
      1 => ts('Exclude'),
      2 => ts('Include by Privacy Option(s)'),
    );
    $form->addRadio('privacy_toggle', ts('Privacy Options'), $options);


    $form->add('select', 'related_group_id', ts('Group'), $groups, true, array('id' => 'related_group_id', 'multiple' => 'multiple', 'title' => ts('- select -')));

    $relationship_types = $this->getRelationshipTypes();
    $form->add('select', 'relationship_type_id', ts('Relationship type'), $relationship_types, false, array('id' => 'relationship_type_id', 'multiple' => 'multiple', 'title' => ts('- Any relationship -')));

    $operator = array('in' => ts("Including related contacts"), 'not in' => ts("Excluding related contacts"));
    $form->add('select', 'including_excluding', ts('Include/exclude'), $operator, true);
    $form->setDefaults(array(
      'including_excluding' => 'not in',
      'is_deceased' => '0',
    ));
  }

  /**
   * Get a list of displayable columns
   *
   * @return array, keys are printable column headers and values are SQL column names
   */
  function &columns() {
    // return by reference
    $columns = array(
      ts('Contact Id') => 'contact_id',
      ts('Name') => 'sort_name',
      ts('Street') => 'street_address',
      ts('Postal code') => 'postal_code',
      ts('City') => 'city',
    );
    return $columns;
  }

  function count() {
    return CRM_Core_DAO::singleValueQuery($this->sql('count(distinct contact_a.id) as total'));
  }

  /**
   * Construct a full SQL query which returns one page worth of results
   *
   * @param int $offset
   * @param int $rowcount
   * @param null $sort
   * @param bool $includeContactIDs
   * @param bool $justIDs
   * @return string, sql
   */
  function all($offset = 0, $rowcount = 0, $sort = NULL, $includeContactIDs = FALSE, $justIDs = FALSE) {
    // delegate to $this->sql(), $this->select(), $this->from(), $this->where(), etc.
    return $this->sql($this->select(), $offset, $rowcount, $sort, $includeContactIDs, NULL);
  }

  /**
   * @param $selectClause
   * @param int $offset
   * @param int $rowcount
   * @param null $sort
   * @param bool $includeContactIDs
   * @param null $groupBy
   *
   * @return string
   */
  function sql(
    $selectClause,
    $offset = 0,
    $rowcount = 0,
    $sort = NULL,
    $includeContactIDs = FALSE,
    $groupBy = NULL
  ) {

    $sql = "SELECT DISTINCT $selectClause " . $this->from();
    $where = $this->where();
    if (!empty($where)) {
      $sql .= " WHERE " . $where;
    }

    if ($includeContactIDs) {
      $this->includeContactIDs($sql,
        $this->_formValues
      );
    }

    if ($groupBy) {
      $sql .= " $groupBy ";
    }

    $this->addSortOffset($sql, $offset, $rowcount, $sort);
    return $sql;
  }

  /**
   * Construct a SQL SELECT clause
   *
   * @return string, sql fragment with SELECT arguments
   */
  function select() {
    return "
      contact_a.id           as contact_id  ,
      contact_a.contact_type as contact_type,
      contact_a.sort_name    as sort_name,
      civicrm_address.street_address    as street_address,
      civicrm_address.postal_code    as postal_code,
      civicrm_address.city    as city
    ";
  }

  /**
   * Construct a SQL FROM clause
   *
   * @return string, sql fragment with FROM and JOIN clauses
   */
  function from() {
    return "
      FROM      civicrm_contact contact_a
      LEFT JOIN civicrm_address ON civicrm_address.is_primary = 1 AND civicrm_address.contact_id = contact_a.id
      LEFT JOIN civicrm_group_contact ON civicrm_group_contact.contact_id = contact_a.id AND civicrm_group_contact.status = 'Added'
      ";
  }

  /**
   * Construct a SQL WHERE clause
   *
   * @param bool $includeContactIDs
   * @return string, sql fragment with conditional expressions
   */
  function where($includeContactIDs = FALSE) {
    $params = array();

    $clauses = array();
    $clauses[] = 'contact_a.is_deleted = 0';

    $group_id   = implode(", ", CRM_Utils_Array::value('group_id', $this->_formValues));
    $clauses[] = "civicrm_group_contact.group_id IN ({$group_id})";

    $relationship_type_clause = "";
    $relationship_type = CRM_Utils_Array::value('relationship_type_id', $this->_formValues);
    foreach($relationship_type as $id => $rid) {
      if (empty($rid)) {
        unset($relationship_type[$id]);
      }
    }
    if (count($relationship_type) > 0) {
      $relationship_type_clause = " AND rel.relationship_type_id IN (".implode(", ", $relationship_type).")";
    }

    $operator = 'IN';
    if (CRM_Utils_Array::value('including_excluding', $this->_formValues) == 'not in') {
      $operator = 'NOT IN';
    }
    $related_group_id   = implode(", ", CRM_Utils_Array::value('related_group_id', $this->_formValues));
    $clauses[] = "contact_a.id {$operator} (
SELECT 
    primary_contact.id
FROM
    civicrm_contact primary_contact
INNER JOIN
    civicrm_relationship rel ON (rel.contact_id_a = primary_contact.id OR rel.contact_id_b = primary_contact.id) {$relationship_type_clause}
INNER JOIN
    civicrm_contact related_contact ON 
        (rel.contact_id_a = primary_contact.id
        AND rel.contact_id_b = related_contact.id)
        OR (rel.contact_id_b = primary_contact.id
        AND rel.contact_id_a = related_contact.id)
INNER JOIN
    civicrm_group_contact related_group_contact ON related_group_contact.contact_id = related_contact.id
WHERE
    contact_a.is_deleted = 0 
    AND related_group_contact.status = 'Added'
    AND related_group_contact.group_id IN ({$related_group_id})
)";


    $privacy_options = $this->_formValues['privacy_options'];
    if (!empty($privacy_options)) {
      // get the operator and toggle values
      $privacyToggle = $this->_formValues['privacy_toggle'];
      $compareOP = '!=';
      if ($privacyToggle && $privacyToggle == 2) {
        $compareOP = '=';
      }

      foreach ($privacy_options as $dontCare => $pOption) {
        $clauses[] = " ( contact_a.{$pOption} $compareOP 1 ) ";
      }
    }

    $is_deceased = $this->_formValues['is_deceased'];
    if ($is_deceased == '1') {
      $clauses[] = "contact_a.is_deceased = '1'";
    } elseif ($is_deceased == '0') {
      $clauses[] = "contact_a.is_deceased = '0'";
    }

    $where = implode(' AND ', $clauses);

    return $this->whereClause($where, $params);
  }

  /**
   * Determine the Smarty template for the search screen
   *
   * @return string, template path (findable through Smarty template path)
   */
  function templateFile() {
    return 'CRM/Relatedcontactingroup/Form/Search/ContactInGroup.tpl';
  }
}
