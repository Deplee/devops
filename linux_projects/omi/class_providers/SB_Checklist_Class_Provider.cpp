/* @migen@ */
#include <MI.h>
#include "SB_Checklist_Class_Provider.h"
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>

MI_BEGIN_NAMESPACE

SB_Checklist_Class_Provider::SB_Checklist_Class_Provider(
    Module* module) :
    m_Module(module)
{
}

SB_Checklist_Class_Provider::~SB_Checklist_Class_Provider()
{
}

void SB_Checklist_Class_Provider::Load(
        Context& context)
{
    context.Post(MI_RESULT_OK);
}

void SB_Checklist_Class_Provider::Unload(
        Context& context)
{
    context.Post(MI_RESULT_OK);
}

void SB_Checklist_Class_Provider::EnumerateInstances(
    Context& context,
    const String& nameSpace,
    const PropertySet& propertySet,
    bool keysOnly,
    const MI_Filter* filter)
{

//class
        SB_Checklist_Class checklist;

        //strings
        std::string FIO;
        std::string ZNO;
        std::string Date;
        std::string WiFi;
	std::string BLTH;
        std::string BRCD;
        std::string TM;
        std::string MFU;
        std::string BP;
        std::string POS;
        std::string WebCam;

        //system query command
        system("if grep '/' /home/tcadmin/check_sbs; then cat /home/tcadmin/check_sbs > /var/tmp/Checklist; else printf 'NULL\nNULL\nNULL\nNULL\nNULL\nNULL\nNULL\nNULL\nNULL\nNULL\nNULL' > /var/tmp/Checklist; fi;");
        //open file
        std::ifstream pathtoChecklistSBS("/var/tmp/Checklist");
        std::ifstream pathtoCheckLogSBS("/home/tcadmin/check_sbs");
        //get strings
        getline(pathtoChecklistSBS, FIO);
        getline(pathtoChecklistSBS, ZNO);
        getline(pathtoChecklistSBS, Date);
        getline(pathtoChecklistSBS, WiFi);
        getline(pathtoChecklistSBS, BLTH);
	getline(pathtoChecklistSBS, BRCD);
        getline(pathtoChecklistSBS, TM);
        getline(pathtoChecklistSBS, MFU);
        getline(pathtoChecklistSBS, BP);
        getline(pathtoChecklistSBS, POS);
        getline(pathtoChecklistSBS, WebCam);

        //get strings
        checklist.FIO_value(FIO.c_str());
        checklist.ZNO_value(ZNO.c_str());
        checklist.Date_value(Date.c_str());
        checklist.WiFi_value(WiFi.c_str());
        checklist.BLTH_value(BLTH.c_str());
	checklist.BRCD_value(BRCD.c_str());
        checklist.TM_value(TM.c_str());
        checklist.MFU_value(MFU.c_str());
        checklist.BP_value(BP.c_str());
        checklist.POS_value(POS.c_str());
        checklist.WebCam_value(WebCam.c_str());

        //close file & remove it
        pathtoChecklistSBS.close();
        pathtoCheckLogSBS.close();
        remove("/var/tmp/Checklist");
        remove("/home/tcadmin/check_sbs");
        // post values
        context.Post(checklist);
        context.Post(MI_RESULT_OK);

}

void SB_Checklist_Class_Provider::GetInstance(
    Context& context,
    const String& nameSpace,
    const SB_Checklist_Class& instanceName,
    const PropertySet& propertySet)
{
    context.Post(MI_RESULT_NOT_SUPPORTED);
}

void SB_Checklist_Class_Provider::CreateInstance(
    Context& context,
    const String& nameSpace,
    const SB_Checklist_Class& newInstance)
{
    context.Post(MI_RESULT_NOT_SUPPORTED);
}

void SB_Checklist_Class_Provider::ModifyInstance(
    Context& context,
    const String& nameSpace,
    const SB_Checklist_Class& modifiedInstance,
    const PropertySet& propertySet)
{
    context.Post(MI_RESULT_NOT_SUPPORTED);
}

void SB_Checklist_Class_Provider::DeleteInstance(
    Context& context,
    const String& nameSpace,
    const SB_Checklist_Class& instanceName)
{
    context.Post(MI_RESULT_NOT_SUPPORTED);
}


MI_END_NAMESPACE
