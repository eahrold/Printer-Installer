//
//  PrinterCUPSExtensions.h
//  Printer-Installer
//
//  Created by Eldon on 1/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//
#import <cups/cups.h>

#ifndef Printer_Installer_PrinterCUPSExtensions_h
#define Printer_Installer_PrinterCUPSExtensions_h

typedef union _ipp_request_u
{
    struct	    {
        ipp_uchar_t  version[2];
        ipp_status_t status_code;
        int          request_id;
    }                status;
    
} _ipp_request_t;


typedef union _ipp_value_u
{
    struct
    {
        char	*language;
        char	*text;
    }           string;
    ipp_t		*collection;
} _ipp_value_t;

typedef _ipp_value_t ipp_value_t;

struct _ipp_attribute_s
{
    ipp_attribute_t *next;
    ipp_tag_t	group_tag,
    value_tag;
    char		*name;
    int         num_values;
    _ipp_value_t	values[1];
};

struct _ipp_s
{
    ipp_state_t		state;
    _ipp_request_t	request;
    ipp_attribute_t	*attrs;
    ipp_attribute_t	*last;
    ipp_attribute_t	*current;
    ipp_tag_t		curtag;
    ipp_attribute_t	*prev;
    
    int			use;
};



#endif
