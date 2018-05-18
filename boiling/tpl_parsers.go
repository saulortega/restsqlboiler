package boiling

var tplParsers = `// Code generated by RESTSQLBoiler (https://github.com/saulortega/restsqlboiler). DO NOT EDIT.

package models

import (
	"errors"
	"gopkg.in/volatiletech/null.v6"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"
)


func parseBoolFromForm(r *http.Request, field string, errorOnBlank bool) (bool, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc bool

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.ParseBool(vo)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseIntFromForm(r *http.Request, field string, errorOnBlank bool) (int, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc int

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.Atoi(vo)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseInt64FromForm(r *http.Request, field string, errorOnBlank bool) (int64, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc int64

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.ParseInt(vo, 10, 64)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseFloat64FromForm(r *http.Request, field string, errorOnBlank bool) (float64, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc float64

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	vc, err = strconv.ParseFloat(vo, 64)
	if err != nil {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseTimeFromForm(r *http.Request, field string, errorOnBlank bool) (time.Time, error) {
	var vo = strings.TrimSpace(r.FormValue(field))
	var err error
	var vc time.Time

	if vo == "" {
		if errorOnBlank {
			err = errors.New("field «"+field+"» can not be blank")
		}
		return vc, err
	}

	if regexp.MustCompile("^[012][0-9]:[0-5][0-9]$").MatchString(vo) {
		vc, err = time.Parse("15:04", vo)
	} else if regexp.MustCompile("^[012][0-9]:[0-5][0-9]:[0-5][0-9]$").MatchString(vo) {
		vc, err = time.Parse("15:04:05", vo)
	} else if regexp.MustCompile("^[012][0-9]:[0-5][0-9] [AP]M$").MatchString(vo) {
		vc, err = time.Parse("15:04 PM", vo)
	} else if regexp.MustCompile("^[012][0-9]:[0-5][0-9]:[0-5][0-9] [AP]M$").MatchString(vo) {
		vc, err = time.Parse("15:04:05 PM", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9]$").MatchString(vo) { // aaaa-mm-dd
		vc, err = time.Parse("2006-01-02", vo)
	} else if regexp.MustCompile("^[0-3][0-9]/[01][0-9]/[0-9]{4}$").MatchString(vo) { // dd/mm/aaaa
		vc, err = time.Parse("02/01/2006", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9] [012][0-9]:[0-5][0-9]:[0-5][0-9]$").MatchString(vo) { // aaaa-mm-dd HH:MM:SS
		vc, err = time.Parse("2006-01-02 15:04:05", vo)
	} else if regexp.MustCompile("^[0-3][0-9]/[01][0-9]/[0-9]{4} [012][0-9]:[0-5][0-9]:[0-5][0-9]$").MatchString(vo) { // dd/mm/aaaa HH:MM:SS
		vc, err = time.Parse("02/01/2006 15:04:05", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9]T[012][0-9]:[0-5][0-9]$").MatchString(vo) { // aaaa-mm-ddTHH:MM
		vc, err = time.Parse("2006-01-02T15:04", vo)
	} else if regexp.MustCompile("^[0-9]{4}-[01][0-9]-[0-3][0-9]T[012][0-9]:[0-5][0-9]:[0-5][0-9].").MatchString(vo) {
		pdzs := strings.Split(vo, ".")
		vc, err = time.Parse("2006-01-02T15:04:05", pdzs[0])
	} else {
		err = errors.New("field «"+field+"» has a wrong value")
	}

	return vc, err
}

func parseNullStringFromForm(r *http.Request, field string) null.String {
	v := strings.TrimSpace(r.FormValue(field))
	return null.NewString(v, v != "")
}

func parseNullBoolFromForm(r *http.Request, field string) (null.Bool, error) {
	v, err := parseBoolFromForm(r, field, false)
	return null.NewBool(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullIntFromForm(r *http.Request, field string) (null.Int, error) {
	v, err := parseIntFromForm(r, field, false)
	return null.NewInt(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullInt64FromForm(r *http.Request, field string) (null.Int64, error) {
	v, err := parseInt64FromForm(r, field, false)
	return null.NewInt64(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullFloat64FromForm(r *http.Request, field string) (null.Float64, error) {
	v, err := parseFloat64FromForm(r, field, false)
	return null.NewFloat64(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

func parseNullTimeFromForm(r *http.Request, field string) (null.Time, error) {
	v, err := parseTimeFromForm(r, field, false)
	return null.NewTime(v, (err == nil && strings.TrimSpace(r.FormValue(field)) != "")), err
}

//

func IDFromURL(r *http.Request) (int64, error) {
	p := strings.Split(r.URL.Path, "/")
	s := strings.TrimSpace(p[len(p)-1])
	return strconv.ParseInt(s, 10, 64)
}

//
//
//

func in(S string, SS []string) bool {
	for _, s := range SS {
		if s == S {
			return true
		}
	}

	return false
}

`