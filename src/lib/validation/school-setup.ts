import { z } from "zod";
export const academicYearSchema=z.object({name:z.string().trim().min(4).max(30),startsOn:z.iso.date(),endsOn:z.iso.date()}).refine(v=>v.endsOn>v.startsOn,{path:["endsOn"],message:"End date must be after start date."});
export const classSchema=z.object({name:z.string().trim().min(1).max(80),sortOrder:z.coerce.number().int().min(0).max(999)});
export const sectionSchema=z.object({classId:z.uuid(),name:z.string().trim().min(1).max(40)});
