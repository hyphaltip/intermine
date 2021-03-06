<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib tagdir="/WEB-INF/tags" prefix="mm"%>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<!-- subListDetailsDisplayer.jsp -->

<a name="#" id="sis" style="cursor:pointer" onclick='if(jQuery("#details").is(":hidden")) { jQuery("#co").attr("src", "images/disclosed.gif"); } else { jQuery("#co").attr("src", "images/undisclosed.gif"); } jQuery("#details").toggle("slow");'>
<h3>
    Submissions Details (click to toggle)
    <img src="images/undisclosed.gif" id="co">
</h3>
</a>

<script type="text/javascript" charset="utf-8">

jQuery(document).ready(function () {
jQuery(".tbox").children('doopen').show();
jQuery(".tbox").children('doclose').hide();

jQuery('.tbox').click(function () {
var text = jQuery(this).children('doclose');

if (text.is(':hidden')) {
   jQuery(this).children('doclose').show("slow");
 } else {
     jQuery(this).children('doopen').show("slow");
  }
});

jQuery("doopen").click(function(){
 jQuery(this).toggle("slow");
 return true;
});

jQuery("doclose").click(function(){
  jQuery(this).toggle("slow");
    return true;
});


});

</script>

<div id="details" style="display: block" class="collection-table column-border">

<table >
<thead>
   <tr>
      <td class="head" >
modENCODE Submissions
      </td>
      <td class="head" >
      Data Files
     </td>
      <td class="head" >
      Submissions to other Public repositories
     </td>
      <td class="head" >
      Experimental properties
     </td>
    </tr>
</thead>
<tbody>
<%-- === FILES ============================= --%>
<c:forEach var="subFiles" items="${files}" varStatus="files_status">

<c:set var="sub" value="${subFiles.key}" />
  <tr>
  <td>
  <html:link href="/${WEB_PROPERTIES['webapp.path']}/report.do?id=${sub.id}">
  <c:out value="${sub.title}"><br>${sub.dCCid}</c:out></html:link>
  <br>[<html:link href="/${WEB_PROPERTIES['webapp.path']}/report.do?id=${sub.id}">
  <c:out value="${sub.dCCid}"></c:out></html:link>]
  </td>
  <td>
    <span class="filelink">
      <mm:dataFiles files="${subFiles.value}" dccId="${sub.dCCid}"/>
    </span>
      <mm:getTarball dccId="${sub.dCCid}"/>

<%-- === REPOSITORY ENTRIES ================ --%>
<%-- TODO: use tiles (duplicated code with experiment.jsp) --%>
<c:forEach var="subReposited" items="${reposited}" varStatus="rep_status">
<c:if test="${subReposited.key eq sub}">
<td>

<c:forEach items="${subReposited.value}" var="aRef" varStatus="ref_status" begin="0" end="5">

<c:if test="${ref_status.count < 6}">
${aRef[0]}:
    <c:choose>
<c:when test="${fn:startsWith(aRef[1],'To ')}">
${aRef[1]}
</c:when>
<c:otherwise>
<a href="${aRef[2]}"
    title="see ${aRef[1]} in ${aRef[0]} repository" class="value extlink">
<c:out value="${aRef[1]}" /> </a>
</c:otherwise>
</c:choose>
<br></br>
</c:if>

<c:if test="${ref_status.count == 6}">
<im:querylink text="...All entries in public repositories generated by this submission" skipBuilder="true" title="View all submissions to public repositories (AE, GEO, SRA) for this experiment">
<query name="" model="genomic" view="Submission.DCCid Submission.databaseRecords.database Submission.databaseRecords.accession Submission.databaseRecords.url" sortOrder="Submission.DCCid asc">
<node path="Submission" type="Submission">
</node>
<node path="Submission.DCCid" type="Integer">
<constraint op="=" value="${subReposited.key.dCCid}" description="" identifier="" code="A">
</constraint>
</node>
</query>
</im:querylink>
<br></br>
</c:if>

</c:forEach>

</c:if>
</c:forEach>

<%-- === PROPERTIES ================ --%>
<%-- TODO: use tiles (duplicated code with experiment.jsp) --%>

   <td class="sorting" bgcolor="white">
   <c:set var="thisTypeCount" value="0" />


   <c:forEach items="${sub.experimentalFactors}" var="factor" varStatus="ef_status">

            <c:choose>
            <c:when test="${factor.property != null}">
<c:set var="thisTypeCount" value="${thisTypeCount + 1}"></c:set>
               <c:choose>
               <c:when test="${thisTypeCount <= 5}">
               <c:if test="${!ef_status.first}"><br></c:if>
               <b>${factor.type}</b>:
                 <html:link href="/${WEB_PROPERTIES['webapp.path']}/report.do?id=${factor.property.id}" title="More information about this factor"><c:out value="${factor.name}"/></html:link>
                <span class="tinylink">
                   <im:querylink text="[ALL]" skipBuilder="true" title="View all submissions using this factor">
                     <query name="" model="genomic"
                       view="Submission.DCCid Submission.project.surnamePI Submission.title Submission.experimentType Submission.properties.type Submission.properties.name"
                       sortOrder="Submission.experimentType asc">
                  <node path="Submission.properties.type" type="String">
                    <constraint op="=" value="${factor.type}" description=""
                                identifier="" code="A">
                    </constraint>
                  </node>
                  <node path="Submission.properties.name" type="String">
                    <constraint op="=" value="${factor.name}" description=""
                                identifier="" code="B">
                    </constraint>
                  </node>
                  <node path="Submission.organism.taxonId" type="Integer">
                    <constraint op="=" value="${sub.organism.taxonId}" description=""
                                identifier="" code="C">
                    </constraint>
                  </node>
                </query>
              </im:querylink>
              </span>

<%--if antibody add target gene --%>
<c:if test="${factor.type == ANTIBODY && !fn:contains(factor.name, 'oldid')}">
              <br></br>

              <c:choose>
<c:when test="${fn:length(factor.property.target.symbol) > 1}">
target:<html:link href="/${WEB_PROPERTIES['webapp.path']}/report.do?id=${factor.property.target.id}"
title="More about this target">
<c:out value="${factor.property.target.symbol}"/></html:link>

</c:when>
<c:otherwise>
              target: ${factor.property.targetName}
</c:otherwise>
</c:choose>


</c:if>

</c:when>

<c:when test="${thisTypeCount > 5 && ef_status.last}">
              ...
<br></br>
              <im:querylink text="all ${thisTypeCount} ${factor.type}s" showArrow="true" skipBuilder="true"
              title="View all ${thisTypeCount} ${factor.type} factors of submission ${sub.dCCid}">

<query name="" model="genomic" view="SubmissionProperty.name SubmissionProperty.type" sortOrder="SubmissionProperty.type asc" constraintLogic="A and B">
<node path="SubmissionProperty" type="SubmissionProperty">
</node>
<node path="SubmissionProperty.submissions" type="Submission">
<constraint op="LOOKUP" value="${sub.dCCid}" description="" identifier="" code="A" extraValue="">
</constraint>
</node>
<node path="SubmissionProperty.type" type="String">
<constraint op="=" value="${factor.type}" description="" identifier="" code="B" extraValue="">
</constraint>
</node>
</query>

              </im:querylink>

</c:when>
</c:choose>

</c:when>
               <c:otherwise>
                 <c:out value="${factor.name}"/><c:if test="${!ef_status.last}">,</c:if>
               </c:otherwise>
             </c:choose>
       </c:forEach>
  </td>

<%-- --%>




         </tr>
    </c:forEach>
</tbody>
    </table>

</div>

<!-- /subListDetailsDisplayer.jsp -->