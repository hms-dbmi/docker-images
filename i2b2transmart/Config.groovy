
/***
* transmart Application configuration settings
* this file will be loaded by the tranSMART application when tomcat is restarted
*
*/

/************************
* LEGACY CONFIGS
*************************/
// Lucane index location for documentation search - this is a absolute path on your local deployment
com.recomdata.searchengine.index = "/usr/local/Cellar/tomcat/7.0.41/appdata/transmart/index"

// absolute path to online help system
com.recomdata.searchtool.adminHelpURL=""

com.recomdata.datasetExplorer.inforsense='false'
// set to true to enable gene pattern integration
com.recomdata.datasetExplorer.genePatternEnabled = 'false'
// The tomcat URL that gene pattern is deployed within -usually it's proxyed through apache

com.recomdata.datasetExplorer.genePatternURL='http://23.23.185.167'
// Gene Pattern real URL with port number

com.recomdata.datasetExplorer.genePatternRealURLBehindProxy='http://23.23.185.167:8080'
// default Gene pattern user to start up - each tranSMART user will need a separate user account to be created in Gene Pattern

com.recomdata.datasetExplorer.genePatternUser='biomart'
com.recomdata.datasetExplorer.plinkExcutable = '/usr/local/bin/plink'

// Metadata view
com.recomdata.view.studyview='studydetail'

/************************
* APP CONFIGS
*************************/
// contact email address
com.recomdata.searchtool.contactUs="mailto:jira@hms-dbmi.atlassian.net"

// relative context path to dataset explorer url
com.recomdata.searchtool.datasetExplorerURL="/transmart/datasetExplorer"

// application logo to be used in the login page
com.recomdata.searchtool.largeLogo="transmartlogo.jpg"

// application logo to be used in the search page
com.recomdata.searchtool.smallLogo="transmartlogosmall.jpg"

//Guest Login Configs
com.recomdata.guestAutoLogin=true
com.recomdata.guestUserName='publicuser'

//Configs to hide functionality
com.recomdata.hideSearch='true'
com.recomdata.hideSampleExplorer='true'
com.recomdata.hideClinicalNoteExplorer='true'
com.recomdata.hideSequenceVariantExplorer='true'
com.recomdata.hideGeneSignature='true'

//i2b2 Configs
com.recomdata.datasetExplorer.pmServiceURL = "http://i2b2-wildfly:9090/i2b2/services/PMService/"
com.recomdata.datasetExplorer.pmServiceProxy='true'

com.recomdata.datasetExplorer.imageTempDir='/images/datasetExplorer'


/**********************************
* configuration for solr
**********************************/

// solr application URL
com.recomdata.solr.baseURL = ""

//This is the max number of results we retrieve
com.recomdata.solr.maxRows = '1000000'

//This is the field that holds the contact e-mail if present.
sampleExplorer.contactfield = 'CONTACT'

//This is the field that identifies a record from the source data. Presumably this could be sent to the contact person to get more information about a sample.
sampleExplorer.idfield = 'SAMPLE_NAME'

//This is the height and width of the grids in Sample Explorer.
sampleExplorer.resultsGridHeight=800
sampleExplorer.resultsGridWidth=1200

//This is the number of results we display before drawing the "More [+]" text.
com.recomdata.solr.maxLinksDisplayed = 5

//This is the maximum number of news stories we display.
com.recomdata.solr.maxNewsStories = 10

//This is the number of items we display in the search suggestion box.
com.recomdata.solr.numberOfSuggestions = 20

//This is an object to dictate the names and 'pretty names' of the SOLR fields. Optionally you can set the width of each of the columns when rendered.
sampleExplorer.fieldMapping = [
												columns:[
													[header:'Analysis', dataIndex:'ANALYSIS', mainTerm: true, showInGrid: true, width:10],
													[header:'Facility',dataIndex:'FACILITY', mainTerm: true, showInGrid: true, width:10],
													[header:'Inventory Status',dataIndex:'INVENTORY_STATUS', mainTerm: true, showInGrid: true, width:10],
													[header:'Protocol Title',dataIndex:'PROTOCOL_TITLE', mainTerm: true, showInGrid: true, width:30],
													[header:'Assay',dataIndex:'ASSAY', mainTerm: true, showInGrid: false],
													[header:'Gender',dataIndex:'GENDER', mainTerm: true, showInGrid: true, width:10],
													[header:'Platform',dataIndex:'PLATFORM', mainTerm: true, showInGrid: true, width:10],
													[header:'Collection Description',dataIndex:'COLLECTION_DESC', mainTerm: true, showInGrid: false],
													[header:'Instrument',dataIndex:'INSTRUMENT', mainTerm: true, showInGrid: false],
													[header:'Proband Status',dataIndex:'PROBAND_STATUS', mainTerm: true, showInGrid: true, width:5],
													[header:'A260 ng/ul',dataIndex:'A260_NG_UL', mainTerm: false, showInGrid: false],
													[header:'Sample Type',dataIndex:'SAMPLE_TYPE', mainTerm: true, showInGrid: true, width:10],
													[header:'Sample Name',dataIndex:'SAMPLE_NAME', mainTerm: false, showInGrid: false],
													[header:'Sample ID',dataIndex:'id', mainTerm: false, showInGrid: false],
													[header:'Study ID',dataIndex:'STUDY_ID', mainTerm: false, showInGrid: false, width:5],
													[header:'Contact',dataIndex:'CONTACT', mainTerm: false, showInGrid: true],
												]
											]

edu.harvard.transmart.sampleBreakdownMap = [
												"PATIENT_NUM":"Patients in Cohort with samples",
												"SAMPLE_NAME":"Samples in Cohort",
												"id":"Aliquots in Cohort"
											]

clinicalNoteExplorer.fieldMapping = [
	columns:[
			[header:"Term", dataIndex:'STR', mainTerm:true, showInGrid: true, width:90],
			[header:"CUI", dataIndex:'NBCUI', mainTerm:true, showInGrid: true, width:10]
		]


]
//**************************


/**********************************
* configuration for plugins
**********************************/

//This is the main temporary directory, under this should be the folders that get created per job.
com.recomdata.plugins.tempFolderDirectory = "/mnt/tmp/jobs/"

//Use this to do local development.  It causes the analysis controllers to move the image file before rendering it.
com.recomdata.plugins.transferImageFile = true

//list of available plugins.
com.recomdata.plugins.available = ["lineGraph","correlationAnalysis","scatterPlot"]

com.recomdata.transmart.data.export.rScriptDirectory = "/usr/local/Cellar/tomcat/7.0.41/applications/transmart/dataExportRScripts"

/**********************************************
* configuration for Spring Security Core Plugin
***********************************************/

// Added by the Spring Security Core plugin:
// customized user GORM class

grails.plugins.springsecurity.userLookup.userDomainClassName = 'edu.hms.transmart.security.AuthUser'
// customized password field

grails.plugins.springsecurity.userLookup.passwordPropertyName = 'passwd'
// customized user /role join GORM class

grails.plugins.springsecurity.userLookup.authorityJoinClassName = 'edu.hms.transmart.security.AuthUser'
// customized role GORM class

grails.plugins.springsecurity.authority.className = 'Role'
// request map GORM class name - request map is stored in the db

grails.plugins.springsecurity.requestMap.className = 'Requestmap'
// requestmap in db

grails.plugins.springsecurity.securityConfigType = grails.plugins.springsecurity.SecurityConfigType.Requestmap
// url to redirect after login in

grails.plugins.springsecurity.successHandler.defaultTargetUrl = '/userLanding'
// logout url

grails.plugins.springsecurity.logout.afterLogoutUrl='/'
// password encoding url

grails.plugins.springsecurity.password.algorithm = 'SHA'

grails.plugins.springsecurity.errors.login.exceeded='Sorry, your account has been locked after too many login attempts.<br /> Please contact an administrator to have your account enabled again.<br />'
grails.plugins.springsecurity.errors.login.fail="Login failed with that username and password combination."
edu.harvard.transmart.bannermessage="Please click one of the buttons below to log in."

//Quartz jobs configuration
//start delay for the sweep job
com.recomdata.export.jobs.sweep.startDelay=60000 //d*h*m*s*1000
//repeat interval for the sweep job
com.recomdata.export.jobs.sweep.repeatInterval= 86400000 //d*h*m*s*1000
//specify the age of files to be deleted (in days)
com.recomdata.export.jobs.sweep.fileAge=3

//**************************

log4j = {
  appenders {
                // set up a log file in the standard tomcat area; be sure to use .toString() with ${}
                rollingFile name:'tomcatLog', file:"transmart.log".toString(), maxFileSize:'6080KB', layout:pattern(conversionPattern: '%d{ISO8601} %d{zz} [%p] (%c{5}:%M:%L) %m%n')
        }

        root {
                // change the root logger to my tomcatLog file
                debug 'tomcatLog'
                additivity = true
        }

        // example for sending stacktraces to my tomcatLog file
        //debug tomcatLog:'StackTrace'
        //debug tomcatLog:'grails.app.task', 'grails.app.controller', 'grails.app.service'

    //trace 'org.hibernate.type'
    //debug 'org.hibernate.SQL'

}
//**************************


//**************************
//Node Metadata Configurations
nodemetadata.fieldMapping =  [
				DOCUMENT_COUNT:[header:'Distinct Documents',treeText:'DC:', fieldType:'count'],
				PATIENT_COUNT:[header:'Patient Count',treeText:'PC:', fieldType:'count'],
				PATIENT_FREQUENCY:[header:'Patient Frequency',treeText:'PF:', fieldType:'percent']
			     ]
nodemetadata.modifierTypeForDetailedUsage = "CUSTOM:SENT:"
//**************************


//**************************
//Validation Parameters
validation.concept_path="\\\\BLANK\\\\"
validation.applied_path="\\\\\\\\BLANK\\\\"

validation.concept_path_public="\\\\BLANK\\\\"
validation.applied_path_public="\\\\\\\\BLANK\\\\"


nodemetadata.observationValidModifier="CUSTOM:OBSERVATION_VALID:"
nodemetadata.conceptValidatedModifier="CUSTOM:CONCEPT_VALIDATED:"
nodemetadata.observationInvalidReasonModifier="CUSTOM:OBSERVATION_INVALID_REASON:"
nodemetadata.patientValidModifier="CUSTOM:PATIENT_VALID:"
nodemetadata.highlightModifier="CUSTOM:HIGHLIGHT:"
//**************************

com.recomdata.plugins.pluginScriptDirectory = "<%= tomcat %>/plugins/"
com.recomdata.plugins.temporaryImageFolder = "<%= tomcat %>/web-app/images/tempImages/"
com.recomdata.plugins.analysisImageURL = "<%= tomcat %>/images/tempImages/"

com.recomdata.administrator = "jira@hms-dbmi.atlassian.net"

com.recomdata.searchtool.appTitle="Department of Biomedical Informatics – tranSMART"

// *************************
// ***    Auth0 Setup    ***
// *************************

// The callback URI has to match the Auth0 'Callback' setting (at least one of them)
edu.harvard.transmart.auth0.callback="/login/callback"

edu.harvard.transmart.auth0.client_id="${System.getenv("AUTH0_CLIENT_ID")}"
edu.harvard.transmart.auth0.client_secret="${System.getenv("AUTH0_CLIENT_SECRET")}"
edu.harvard.transmart.auth0.domain="${System.getenv("AUTH0_DOMAIN")}"

// *************************
// ***  reCAPTCHA Setup  ***
// *************************

edu.harvard.transmart.captcha.secret="${System.getenv("GOOGLE_RECAPTCHA_SECRET")}"
edu.harvard.transmart.captcha.sitekey="${System.getenv("GOOGLE_RECAPTCHA_SITEKEY")}"
edu.harvard.transmart.captcha.verifyurl="https://www.google.com/recaptcha/api/siteverify"

// **************************
// ***     Email Setup    ***
// **************************

edu.harvard.transmart.email.port="587"
edu.harvard.transmart.email.server="smtp.gmail.com"
edu.harvard.transmart.email.user="hms.dbmi.data.infrastructure@gmail.com"
edu.harvard.transmart.email.password="${System.getenv("EMAIL_PASS")}"

// The sending e-mail address has to match/valid on the "email.server" server above!!!
edu.harvard.transmart.email.from="HMS-DBMI DataInfrastructure Support <hms.dbmi.data.infrastructure@gmail.com>"

// Internal support e-mail communication will be sent to this. Usually a list of emails, separated by commas
edu.harvard.transmart.email.support="jira@hms-dbmi.atlassian.net"
edu.harvard.transmart.email.notify="${System.getenv("NOTIFICATION_EMAILS")}"

edu.harvard.transmart.googleanalytics.tracking="${System.getenv("GOOGLE_TRACKING")}"
edu.harvard.transmart.email.smtp_timeout="180000" // in miliseconds
edu.harvard.transmart.email.isdebug="false"
edu.harvard.transmart.email.logo="http://dbmi.hms.harvard.edu/profiles/hmssf/themes/custom/hms_bootstrap/logo.png"


// Additional properties
edu.harvard.transmart.instance.name="${System.getenv("APPLICATION_NAME")}"
edu.harvard.transmart.instance.type=""
edu.harvard.transmart.isPublicStudyRestricted="true"
edu.harvard.transmart.access.level1="manual"

// *************************
// ***    Export Setup   ***
// *************************
edu.harvard.transmart.data.export.transferToS3=true
edu.harvard.transmart.S3BucketName="${System.getenv("S3_BUCKET_NAME")}"
edu.harvard.transmart.rServeHost="${System.getenv("RSERVE_HOST")}"
edu.harvard.transmart.rServePort=${System.getenv("RSERVE_PORT")}

//Path on the remote file server (S3) where we can store the job files.
//no starting slash and make sure there is a slash at the end! e.g.: tmp/jobs/
edu.harvard.transmart.transfer.fileServerTempPath="tmp/jobs/"

//Path on the R server we can store the job files.
edu.harvard.transmart.transfer.rServerTempPath="/mnt/tmp/jobs"

//Path on the local server to write the files before moving to file server.
edu.harvard.transmart.transfer.localServerTempPath="/mnt/tmp/jobs"

//Location of the Pivot R Script
com.recomdata.transmart.data.export.rScriptDirectory = "https://raw.githubusercontent.com/hms-dbmi/tranSMART-R-Scripts/master/dataExportRScripts/"

edu.harvard.transmart.instance.userguideurl="https://example.com/SomeUserguideUrl.html"
